defmodule ExBanking.BalanceDynamicSupervisor do
  @moduledoc false

  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def spawn_balance(user, currency) do
    child_spec = %{
      id: ExBanking.BalanceManager,
      start: {ExBanking.BalanceManager, :start_link, [{user, currency}, []]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
