defmodule ExBanking.Semaphore do
  @moduledoc false

  @user_operations_max_concurrency 10

  def call(function, entity, entity_type) do
    entity
    |> do_call_semaphore(function)
    |> handle_semaphore_result(entity_type)
  end

  defp do_call_semaphore(entity, function) do
    Semaphore.call(entity, @user_operations_max_concurrency, function)
  end

  defp handle_semaphore_result({:error, :max}, suffix) do
    {:error, String.to_existing_atom("too_many_requests_to_#{suffix}")}
  end

  defp handle_semaphore_result(result, _suffix), do: result
end
