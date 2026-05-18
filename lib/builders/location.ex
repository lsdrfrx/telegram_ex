defmodule TelegramEx.Builder.Location do
  @moduledoc """
  Builder for location payloads.

  This module provides a fluent API for sending geographic coordinates.

  ## Examples

      # Send location coordinates
      ctx
      |> Location.coordinates(40.7128, -74.0060)
      |> Location.send(chat_id)

      # Send location silently
      ctx
      |> Location.coordinates(55.7558, 37.6173)
      |> Location.silent()
      |> Location.send(chat_id)
  """

  alias TelegramEx.API

  @doc """
  Sets the geographic coordinates.

  ## Parameters

  - `ctx` - Context map
  - `lat` - Latitude
  - `lng` - Longitude

  ## Returns

  Updated context map with coordinates set.

  ## Examples

      # New York City coordinates
      ctx
      |> Location.coordinates(40.7128, -74.0060)
      |> Location.send(chat_id)
  """
  @spec coordinates(map(), float(), float()) :: map()
  def coordinates(ctx, lat, lng) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:latitude, lat)
    |> Map.put(:longitude, lng)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sends the location without notification sound.

  ## Parameters

  - `ctx` - Context map

  ## Returns

  Updated context map with silent flag set.
  """
  @spec silent(map()) :: map()
  def silent(ctx) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:disable_notification, true)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sends the location to the specified chat.

  ## Parameters

  - `ctx` - Context map with accumulated location data
  - `id` - Chat ID to send the location to

  ## Returns

  - `:ok` - Location sent successfully
  - `{:error, reason}` - Failed to send location
  """
  @spec send(map(), integer()) :: :ok | {:error, term()}
  def send(ctx, id) do
    ctx
    |> Map.put(:chat_id, id)
    |> Map.put(:method, "sendLocation")
    |> Map.put(:format, :json)
    |> API.request()
  end
end
