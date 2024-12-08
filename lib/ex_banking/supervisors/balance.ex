defmodule ExBanking.BalanceSupervisor do
  @moduledoc false

  use Supervisor
  require Logger

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      {ExBanking.BalanceRegistry, []},
      {ExBanking.BalanceDynamicSupervisor, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
