defmodule ExBanking.UserDynamicSupervisor do
  @moduledoc false

  use DynamicSupervisor

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def spawn_user(user) do
    child_spec = %{
      id: ExBanking.UserManager,
      start: {ExBanking.UserManager, :start_link, [user, []]},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end
