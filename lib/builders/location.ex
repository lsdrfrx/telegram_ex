defmodule TelegramEx.Builder.Location do
  @moduledoc """
  Builder for location payloads.

      Location.coordinates(40.7128, -74.0060)
      |> Location.send(chat_id)
  """

  alias TelegramEx.API

  def coordinates(lat, lng) do
    %{latitude: lat, longitude: lng}
  end

  def send(location, id) do
    location
    |> Map.put(:chat_id, id)
    |> then(&API.request(Process.get(:token), "sendLocation", &1))
  end
end
