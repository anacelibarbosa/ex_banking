defmodule ExBanking.Users do
  @moduledoc false

  alias ExBanking.UserDynamicSupervisor
  alias ExBanking.UserRegistry
  alias ExBanking.Users.Balances

  @type amount :: number()

  @type currency :: String.t()
  @type user :: String.t()
  @type from_user :: String.t()
  @type to_user :: String.t()

  @type result_tuple :: {:ok, any()} | {:error, any()}

  @spec create_user(user) :: :ok | {:error, :user_already_exists}
  def create_user(user) do
    case UserDynamicSupervisor.spawn_user(user) do
      {:ok, _pid} ->
        :ok

      {:error, {:already_started, _pid}} ->
        {:error, :user_already_exists}
    end
  end

  @spec get_user(user) :: {:ok, any()} | {:error, :user_does_not_exist}
  def get_user(user) do
    case UserRegistry.lookup_user(user) do
      {:error, :not_found} -> {:error, :user_does_not_exist}
      {:ok, pid} -> {:ok, pid}
    end
  end

  @spec get_user_balance(user, currency) :: result_tuple
  def get_user_balance(user, currency) do
    Balances.get_balance(user, currency)
  end

  @spec deposit_amount_to_balance(user, currency, amount) :: {:ok, any()}
  def deposit_amount_to_balance(user, currency, amount) do
    Balances.deposit_amount(user, currency, amount)
  end

  @spec withdraw_amount_from_balance(user, currency, amount) :: result_tuple
  def withdraw_amount_from_balance(user, currency, amount) do
    Balances.withdraw_amount(user, currency, amount)
  end

  @spec transfer_funds(from_user, to_user, currency, amount) :: result_tuple
  def transfer_funds(from_user, to_user, currency, amount) do
    Balances.transfer_amount(from_user, to_user, currency, amount)
  end
end
