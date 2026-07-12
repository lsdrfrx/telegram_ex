defmodule TelegramEx.Types.Location do
  @moduledoc """
  Struct representing a Telegram Location object.

  Contains information about a point on the map.

  ## Fields

  - `:latitude` - Latitude as defined by the sender
  - `:longitude` - Longitude as defined by the sender
  - `:horizontal_accuracy` - Radius of uncertainty in meters (nil if not available)
  - `:live_period` - Live location update period in seconds (nil if not available)
  - `:heading` - Direction of movement in degrees (nil if not available)
  - `:proximity_alert_radius` - Maximum distance for proximity alerts (nil if not available)

  """

  alias TelegramEx.Types

  @typedoc """
  Location struct type.
  """
  @type t :: %__MODULE__{
          latitude: float(),
          longitude: float(),
          horizontal_accuracy: Types.nullable(float()),
          live_period: Types.nullable(integer()),
          heading: Types.nullable(integer()),
          proximity_alert_radius: Types.nullable(integer())
        }

  defstruct [
    :latitude,
    :longitude,
    :horizontal_accuracy,
    :live_period,
    :heading,
    :proximity_alert_radius
  ]

  @doc """
  Converts a raw Telegram API location map to a Location struct.
  """
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      latitude: map["latitude"],
      longitude: map["longitude"],
      horizontal_accuracy: map["horizontal_accuracy"],
      live_period: map["live_period"],
      heading: map["heading"],
      proximity_alert_radius: map["proximity_alert_radius"]
    }
  end
end
