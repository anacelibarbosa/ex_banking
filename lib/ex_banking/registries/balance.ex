defmodule ExBanking.BalanceRegistry do
  @moduledoc false

  require Logger

  def child_spec(_opts) do
    Registry.child_spec(
      keys: :unique,
      name: __MODULE__
    )
  end

  def lookup_balance(user, currency) do
    case Registry.lookup(__MODULE__, {user, currency}) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end
end
