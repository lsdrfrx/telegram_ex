defmodule TelegramEx.Types.Audio do
  @moduledoc """
  Struct representing a Telegram Audio object.

  Contains information about an audio file to be treated as music.

  ## Fields

  - `:file_id` - Identifier for this file
  - `:file_unique_id` - Stable unique identifier for this file
  - `:duration` - Duration of the audio in seconds
  - `:performer` - Performer of the audio (nil if not available)
  - `:title` - Title of the audio (nil if not available)
  - `:file_name` - Original filename (nil if not available)
  - `:mime_type` - MIME type of the file (nil if not available)
  - `:file_size` - File size in bytes (nil if not available)
  - `:thumbnail` - Album cover thumbnail as a raw PhotoSize map (nil if not available)

  """

  alias TelegramEx.Types

  @typedoc """
  Audio struct type.
  """
  @type t :: %__MODULE__{
          file_id: String.t(),
          file_unique_id: String.t(),
          duration: integer(),
          performer: Types.nullable(String.t()),
          title: Types.nullable(String.t()),
          file_name: Types.nullable(String.t()),
          mime_type: Types.nullable(String.t()),
          file_size: Types.nullable(integer()),
          thumbnail: Types.nullable(map())
        }

  defstruct [
    :file_id,
    :file_unique_id,
    :duration,
    :performer,
    :title,
    :file_name,
    :mime_type,
    :file_size,
    :thumbnail
  ]

  @doc """
  Converts a raw Telegram API audio map to an Audio struct.
  """
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      file_id: map["file_id"],
      file_unique_id: map["file_unique_id"],
      duration: map["duration"],
      performer: map["performer"],
      title: map["title"],
      file_name: map["file_name"],
      mime_type: map["mime_type"],
      file_size: map["file_size"],
      thumbnail: map["thumbnail"]
    }
  end
end
