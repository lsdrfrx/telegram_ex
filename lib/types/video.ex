defmodule TelegramEx.Types.VideoQuality do
  @moduledoc """
  Struct representing a Telegram VideoQuality object.
  """

  alias TelegramEx.Types

  @typedoc """
  VideoQuality struct type.
  """
  @type t :: %__MODULE__{
          file_id: String.t(),
          file_unique_id: String.t(),
          width: integer(),
          height: integer(),
          codec: String.t(),
          file_size: Types.nullable(integer())
        }

  defstruct [
    :file_id,
    :file_unique_id,
    :width,
    :height,
    :codec,
    :file_size
  ]

  @doc """
  Converts a raw Telegram API video quality map to a VideoQuality struct.
  """
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      file_id: map["file_id"],
      file_unique_id: map["file_unique_id"],
      width: map["width"],
      height: map["height"],
      codec: map["codec"],
      file_size: map["file_size"]
    }
  end
end

defmodule TelegramEx.Types.Video do
  @moduledoc """
  Struct representing a Telegram Video object.

  Contains information about a video file.

  ## Fields

  - `:file_id` - Identifier for this file
  - `:file_unique_id` - Stable unique identifier for this file
  - `:width` - Video width
  - `:height` - Video height
  - `:duration` - Duration of the video in seconds
  - `:thumbnail` - Video thumbnail as a raw PhotoSize map (nil if not available)
  - `:cover` - Available sizes of the video cover as raw PhotoSize maps (nil if not available)
  - `:start_timestamp` - Timestamp from which the video plays (nil if not available)
  - `:qualities` - Available video qualities (nil if not available)
  - `:file_name` - Original filename (nil if not available)
  - `:mime_type` - MIME type of the file (nil if not available)
  - `:file_size` - File size in bytes (nil if not available)

  """

  alias TelegramEx.Types
  alias TelegramEx.Types.VideoQuality

  @typedoc """
  Video struct type.
  """
  @type t :: %__MODULE__{
          file_id: String.t(),
          file_unique_id: String.t(),
          width: integer(),
          height: integer(),
          duration: integer(),
          thumbnail: Types.nullable(map()),
          cover: Types.nullable(list(map())),
          start_timestamp: Types.nullable(integer()),
          qualities: Types.nullable(list(VideoQuality.t())),
          file_name: Types.nullable(String.t()),
          mime_type: Types.nullable(String.t()),
          file_size: Types.nullable(integer())
        }

  defstruct [
    :file_id,
    :file_unique_id,
    :width,
    :height,
    :duration,
    :thumbnail,
    :cover,
    :start_timestamp,
    :qualities,
    :file_name,
    :mime_type,
    :file_size
  ]

  @doc """
  Converts a raw Telegram API video map to a Video struct.
  """
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      file_id: map["file_id"],
      file_unique_id: map["file_unique_id"],
      width: map["width"],
      height: map["height"],
      duration: map["duration"],
      thumbnail: map["thumbnail"],
      cover: map["cover"],
      start_timestamp: map["start_timestamp"],
      qualities: Types.map(VideoQuality, map["qualities"]),
      file_name: map["file_name"],
      mime_type: map["mime_type"],
      file_size: map["file_size"]
    }
  end
end
