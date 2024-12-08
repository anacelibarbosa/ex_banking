defmodule ExBanking.Balances do
  @moduledoc false

  alias ExBanking.BalanceDynamicSupervisor
  alias ExBanking.BalanceRegistry

  @type user :: String.t()
  @type currency :: String.t()
  @type balance_amount :: number()

  @spec get_balance(user, currency) :: {:ok, balance_amount}
  def get_balance(user, currency) do
    decimal_amount = get_balance_state(user, currency)

    {:ok, Decimal.to_float(decimal_amount)}
  end

  defp get_balance_state(user, currency) do
    pid = get_balance_registry(user, currency)

    :sys.get_state(pid)
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
end
