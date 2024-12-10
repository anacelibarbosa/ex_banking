defmodule ExBanking.BalanceManager do
  @moduledoc false
  use GenServer

  alias ExBanking.BalanceRegistry

  def start_link(balance_id, opts) do
    GenServer.start_link(
      __MODULE__,
      opts,
      name: {:via, Registry, {BalanceRegistry, balance_id}}
    )
  end

  @impl true
  def init(_opts) do
    {:ok, Decimal.new("0.00")}
  end

  @impl true
  def handle_call({operation_type, decimal_amount}, _from, state) do
    case do_operation(operation_type, decimal_amount, state) do
      {:ok, new_state} = result -> {:reply, result, new_state}
      {:error, _err} = error_result -> {:reply, error_result, state}
    end
  end

  defp do_operation(:credit, money_amount, current_balance_amount) do
    new_balance_amount = Decimal.add(money_amount, current_balance_amount)

    {:ok, new_balance_amount}
  end

  defp do_operation(:debit, money_amount, current_balance_amount) do
    new_balance_amount = Decimal.sub(current_balance_amount, money_amount)
    negative_amount? = Decimal.lt?(new_balance_amount, Decimal.new("0.00"))

    if negative_amount? do
      {:error, :not_enough_money}
    else
      {:ok, new_balance_amount}
    end
  end
end
