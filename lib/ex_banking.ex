defmodule ExBanking do
  @moduledoc false

  alias ExBanking.Users

  @type currency :: String.t()
  @type user :: String.t()

  @type balance :: number()

  @type create_user_error :: :wrong_arguments | :user_already_exists
  @type get_balance_error :: :wrong_arguments | :user_does_not_exist | :too_many_requests_to_user

  @spec create_user(user) :: :ok | {:error, create_user_error}
  def create_user(user) do
    with :ok <- validate_string(user) do
      Users.create_user(user)
    end
  end

  @spec get_balance(user, currency) :: {:ok, balance} | {:error, get_balance_error}
  def get_balance(user, currency) do
    with :ok <- validate_string(user),
         :ok <- validate_string(currency),
         {:ok, _user_pid} <- Users.get_user(user),
         {:ok, balance} <- do_get_balance(user, currency) do
      {:ok, Decimal.to_float(balance)}
    else
      {:error, :max} -> {:error, :too_many_requests_to_user}
      error -> error
    end
  end

  defp do_get_balance(user, currency) do
    Semaphore.call(user, 10, fn -> Users.get_user_balance(user, currency) end)
  end

  defp validate_string(string) when is_bitstring(string) and string != "", do: :ok
  defp validate_string(_invalid_string), do: {:error, :wrong_arguments}
end
