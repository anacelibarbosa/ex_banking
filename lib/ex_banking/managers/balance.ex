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
    {:ok, 0.00}
  end
end
