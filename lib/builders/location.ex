defmodule TelegramEx.Builder.Location do
  @moduledoc """
  Builder for location payloads.

  Builds `sendLocation` payloads. See
  [Messages and Media](messages-and-media.md).
  """

  alias TelegramEx.API
  alias TelegramEx.Builder
  alias TelegramEx.Effect

  @type input :: map() | Effect.t()

  @doc """
  Sets the geographic coordinates.
  """
  @spec coordinates(input(), float(), float()) :: Effect.t()
  def coordinates(input, lat, lng) do
    input
    |> Builder.put_payload(:latitude, lat)
    |> Builder.put_payload(:longitude, lng)
  end

  @doc """
  Sends the location without notification sound.
  """
  @spec silent(input()) :: Effect.t()
  def silent(input) do
    Builder.put_payload(input, :disable_notification, true)
  end

  @doc """
  Sends the location to the specified chat.
  """
  @spec send(input(), integer()) :: Effect.t()
  def send(input, id) do
    input
    |> Effect.wrap()
    |> Effect.then(fn ctx ->
      new_ctx =
        ctx
        |> Map.put(:chat_id, id)
        |> Map.put(:method, "sendLocation")
        |> Map.put(:format, :json)

      case API.request(new_ctx) do
        :ok -> {:ok, new_ctx}
        {:error, reason} -> {:error, reason}
      end
    end)
  end
end
