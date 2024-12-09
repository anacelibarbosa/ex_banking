defmodule ExBanking.Users do
  @moduledoc false

  alias ExBanking.UserDynamicSupervisor
  alias ExBanking.UserRegistry
  alias ExBanking.Users.Balances

  @spec create_user(user :: String.t()) :: :ok | {:error, :user_already_exists}
  def create_user(user) do
    case UserDynamicSupervisor.spawn_user(user) do
      {:ok, _pid} ->
        :ok

      {:error, {:already_started, _pid}} ->
        {:error, :user_already_exists}
    end
  end

  @spec get_user(user :: String.t()) :: {:ok, any()} | {:error, :user_does_not_exist}
  def get_user(user) do
    case UserRegistry.lookup_user(user) do
      {:error, :not_found} -> {:error, :user_does_not_exist}
      {:ok, pid} -> {:ok, pid}
    end
  end

  @spec get_user_balance(String.t(), String.t()) :: {:ok, any()} | {:error, any()}
  def get_user_balance(user, currency) do
    Balances.get_balance(user, currency)
  end
end
