defmodule TelegramEx.Builder do
  @moduledoc """
  Shared helpers for TelegramEx builder modules.
  """

  alias TelegramEx.Effect

  @type input :: map() | Effect.t()

  @doc """
  Adds a value to the effect payload.
  """
  @spec put_payload(input(), atom(), term()) :: Effect.t()
  def put_payload(input, key, value) do
    input
    |> Effect.wrap()
    |> Effect.map_ctx(fn ctx ->
      Map.get(ctx, :payload, %{})
      |> Map.put(key, value)
      |> then(&Map.put(ctx, :payload, &1))
    end)
  end
end
