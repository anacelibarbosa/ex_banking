defmodule ExBanking.Users do
  @moduledoc false

  alias ExBanking.UserDynamicSupervisor

  @spec create_user(user :: String.t()) :: :ok | {:error, :user_already_exists}
  def create_user(user) do
    case UserDynamicSupervisor.spawn_user(user) do
      {:ok, _pid} ->
        :ok

      {:error, {:already_started, _pid}} ->
        {:error, :user_already_exists}
    end
  end
end
