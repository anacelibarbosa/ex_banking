defmodule ExBanking.Users do
  @moduledoc false

  alias ExBanking.UserDynamicSupervisor
  alias ExBanking.UserRegistry

  @spec create_user(user :: String.t()) :: :ok | {:error, :user_already_exists}
  def create_user(user) do
    case UserDynamicSupervisor.spawn_user(user) do
      {:ok, _pid} ->
        :ok

      {:error, {:already_started, _pid}} ->
        {:error, :user_already_exists}
    end
  end

  @spec get_user(user :: String.t()) :: {:ok, any()} | {:error, any()}
  def get_user(user) do
    case UserRegistry.lookup_user(user) do
      {:error, :not_found} -> {:error, :user_does_not_exist}
      {:ok, _pid} -> {:ok, user}
    end
  end
end
