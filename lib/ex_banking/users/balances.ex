defmodule ExBanking.Users.Balances do
  @moduledoc false

  alias ExBanking.BalanceDynamicSupervisor
  alias ExBanking.BalanceRegistry

  @spec get_balance(String.t(), String.t()) :: {:ok, any()}
  def get_balance(user, currency) do
    pid = get_balance_registry(user, currency)

    balance = :sys.get_state(pid)

    {:ok, balance}
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
