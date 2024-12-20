defmodule ExBanking.UserRegistry do
  @moduledoc false

  require Logger

  def child_spec(_opts) do
    Registry.child_spec(
      keys: :unique,
      name: __MODULE__
    )
  end

  def lookup_user(user_id) do
    case Registry.lookup(__MODULE__, user_id) do
      [{pid, _}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end
end
