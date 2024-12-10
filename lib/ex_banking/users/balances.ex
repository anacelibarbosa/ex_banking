defmodule ExBanking.Users.Balances do
  @moduledoc false

  alias ExBanking.BalanceDynamicSupervisor
  alias ExBanking.BalanceRegistry

  @spec get_balance(String.t(), String.t()) :: {:ok, any()}
  def get_balance(user, currency) do
    pid = get_balance_registry(user, currency)

    balance = :sys.get_state(pid)

    {:ok, Decimal.to_float(balance)}
  end

  defp get_balance_registry(user, currency) do
    case BalanceRegistry.lookup_balance(user, currency) do
      {:ok, pid} -> pid
      {:error, :not_found} -> create_balance_registry(user, currency)
    end
  end

  defp create_balance_registry(user, currency) do
    case BalanceDynamicSupervisor.spawn_balance(user, currency) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  @spec deposit_amount(String.t(), String.t(), number()) :: any()
  def deposit_amount(user, currency, amount) do
    pid = get_balance_registry(user, currency)
    decimal_amount = number_to_decimal(amount)

    {:ok, balance} = GenServer.call(pid, {:credit, decimal_amount})

    {:ok, Decimal.to_float(balance)}
  end

  @spec withdraw_amount(String.t(), String.t(), number()) :: any()
  def withdraw_amount(user, currency, amount) do
    pid = get_balance_registry(user, currency)
    decimal_amount = number_to_decimal(amount)

    case GenServer.call(pid, {:debit, decimal_amount}) do
      {:ok, new_balance} -> {:ok, Decimal.to_float(new_balance)}
      {:error, :not_enough_money} -> {:error, :not_enough_money}
    end
  end

  @spec transfer_amount(String.t(), String.t(), String.t(), number()) :: any()
  def transfer_amount(from_user, to_user, currency, amount) do
    from_pid = get_balance_registry(from_user, currency)
    to_pid = get_balance_registry(to_user, currency)
    decimal_amount = number_to_decimal(amount)

    with {:ok, new_balance_from} <- GenServer.call(from_pid, {:debit, decimal_amount}),
         {:ok, new_balance_to} <- GenServer.call(to_pid, {:credit, decimal_amount}) do
      {:ok, {Decimal.to_float(new_balance_from), Decimal.to_float(new_balance_to)}}
    else
      {:error, :not_enough_money} -> {:error, :not_enough_money}
    end
  end

  def number_to_decimal(number) when is_float(number) do
    number
    |> Decimal.from_float()
    |> Decimal.round(2)
  end

  def number_to_decimal(number) do
    number
    |> Decimal.new()
    |> Decimal.round(2)
  end
end
