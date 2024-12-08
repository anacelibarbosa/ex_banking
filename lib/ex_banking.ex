defmodule ExBanking do
  @moduledoc false

  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments}
  def create_user(user) do
    with :ok <- validate_string(user) do
      :ok
    end
  end

  defp validate_string(string) when is_bitstring(string) and string != "", do: :ok
  defp validate_string(_invalid_string), do: {:error, :wrong_arguments}
end
