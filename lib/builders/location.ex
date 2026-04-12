defmodule TelegramEx.Builder.Location do
  @moduledoc """
  Builder for location payloads.

      Location.coordinates(ctx, 40.7128, -74.0060)
      |> Location.send(chat_id)
  """

  alias TelegramEx.API

  def coordinates(ctx, lat, lng) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:latitude, lat)
    |> Map.put(:longitude, lng)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def send(ctx, id) do
    ctx
    |> Map.put(:chat_id, id)
    |> Map.put(:method, "sendLocation")
    |> Map.put(:format, :json)
    |> API.request()
  end
end
