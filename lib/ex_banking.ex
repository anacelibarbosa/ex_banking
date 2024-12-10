defmodule ExBanking do
  @moduledoc false

  alias ExBanking.Users

  @user_operations_max_concurrency 10

  @type currency :: String.t()
  @type user :: String.t()
  @type from_user :: String.t()
  @type to_user :: String.t()

  @type amount :: number()
  @type balance :: number()
  @type new_balance :: number()
  @type from_user_balance :: number()
  @type to_user_balance :: number()

  @type create_user_error ::
          :wrong_arguments
          | :user_already_exists

  @type get_balance_error ::
          :wrong_arguments
          | :user_does_not_exist
          | :too_many_requests_to_user

  @type deposit_error ::
          :wrong_arguments
          | :user_does_not_exist
          | :too_many_requests_to_user

  @type withdraw_error ::
          :wrong_arguments
          | :user_does_not_exist
          | :not_enough_money
          | :too_many_requests_to_user

  @type send_error ::
          :wrong_arguments
          | :not_enough_money
          | :sender_does_not_exist
          | :receiver_does_not_exist
          | :too_many_requests_to_sender
          | :too_many_requests_to_receiver

  @type send_result_tuple :: {:ok, from_user_balance, to_user_balance} | {:error, send_error}

  @spec create_user(user) :: :ok | {:error, create_user_error}
  def create_user(user) do
    with :ok <- validate_string(user) do
      Users.create_user(user)
    end
  end

  @spec deposit(user, amount, currency) :: {:ok, new_balance} | {:error, deposit_error}
  def deposit(user, amount, currency) do
    with :ok <- validate_non_neg_number(amount),
         :ok <- validate_string(user),
         :ok <- validate_string(currency),
         {:ok, _user_pid} <- Users.get_user(user),
         {:ok, new_balance} <- do_deposit(user, currency, amount) do
      {:ok, new_balance}
    else
      {:error, :max} -> {:error, :too_many_requests_to_user}
      error -> error
    end
  end

  defp do_deposit(user, currency, amount) do
    Semaphore.call(user, @user_operations_max_concurrency, fn ->
      Users.deposit_amount_to_balance(user, currency, amount)
    end)
  end

  @spec withdraw(user, amount, currency) :: {:ok, new_balance} | {:error, withdraw_error}
  def withdraw(user, amount, currency) do
    with :ok <- validate_non_neg_number(amount),
         :ok <- validate_string(user),
         :ok <- validate_string(currency),
         {:ok, _user_pid} <- Users.get_user(user),
         {:ok, new_balance} <- do_withdraw(user, currency, amount) do
      {:ok, new_balance}
    else
      {:error, :max} -> {:error, :too_many_requests_to_user}
      error -> error
    end
  end

  defp do_withdraw(user, currency, amount) do
    Semaphore.call(user, @user_operations_max_concurrency, fn ->
      Users.withdraw_amount_from_balance(user, currency, amount)
    end)
  end

  @spec get_balance(user, currency) :: {:ok, balance} | {:error, get_balance_error}
  def get_balance(user, currency) do
    with :ok <- validate_string(user),
         :ok <- validate_string(currency),
         {:ok, _user_pid} <- Users.get_user(user),
         {:ok, balance} <- do_get_balance(user, currency) do
      {:ok, balance}
    else
      {:error, :max} -> {:error, :too_many_requests_to_user}
      error -> error
    end
  end

  defp do_get_balance(user, currency) do
    Semaphore.call(user, @user_operations_max_concurrency, fn ->
      Users.get_user_balance(user, currency)
    end)
  end

  @spec send(from_user, to_user, amount, currency) :: send_result_tuple
  def send(from_user, to_user, amount, currency) do
    with :ok <- validate_non_neg_number(amount),
         :ok <- validate_string(from_user),
         :ok <- validate_string(to_user),
         :ok <- validate_string(currency),
         :ok <- validate_user(from_user, :from_user),
         :ok <- validate_user(to_user, :to_user),
         {:ok, new_balance} <- do_transfer(from_user, to_user, currency, amount) do
      {:ok, new_balance}
    else
      {:error, :max} -> {:error, :too_many_requests_to_user}
      {:error, :user_does_not_exist, :from_user} -> {:error, :sender_does_not_exist}
      {:error, :user_does_not_exist, :to_user} -> {:error, :receiver_does_not_exist}
      {:error, :max} -> {:error, :too_many_requests_to_sender}
      error -> error
    end
  end

  defp validate_user(user, type) do
    case Users.get_user(user) do
      {:ok, _pid} -> :ok
      {:error, error} -> {:error, error, type}
    end
  end

  defp do_transfer(from_user, to_user, amount, currency) do
    Semaphore.call(from_user, @user_operations_max_concurrency, fn ->
      case do_transfer_funds(from_user, to_user, currency, amount) do
        {:error, :max} -> {:error, :too_many_requests_to_receiver}
        result -> result
      end
    end)
  end

  defp do_transfer_funds(from_user, to_user, amount, currency) do
    Semaphore.call(to_user, @user_operations_max_concurrency, fn ->
      Users.transfer_funds(from_user, to_user, currency, amount)
    end)
  end

  defp validate_string(string) when is_bitstring(string) and string != "", do: :ok
  defp validate_string(_invalid_string), do: {:error, :wrong_arguments}

  defp validate_non_neg_number(invalid) when not is_number(invalid),
    do: {:error, :wrong_arguments}

  defp validate_non_neg_number(negative) when negative < 0, do: {:error, :wrong_arguments}
  defp validate_non_neg_number(_number), do: :ok
end
