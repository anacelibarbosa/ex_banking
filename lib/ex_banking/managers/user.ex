defmodule ExBanking.UserManager do
  @moduledoc false
  use GenServer

  alias ExBanking.UserRegistry

  def start_link(user_id, opts) do
    GenServer.start_link(
      __MODULE__,
      opts,
      name: {:via, Registry, {UserRegistry, user_id}}
    )
  end

  @impl true
  def init(_opts) do
    {:ok, %{}}
  end
end
