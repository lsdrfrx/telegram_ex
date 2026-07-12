defmodule TelegramEx.Types.Document do
  @moduledoc """
  Struct representing a Telegram Document object.

  Contains information about a general file.

  ## Fields

  - `:file_id` - Identifier for this file
  - `:file_unique_id` - Stable unique identifier for this file
  - `:thumbnail` - Document thumbnail as a raw PhotoSize map (nil if not available)
  - `:file_name` - Original filename (nil if not available)
  - `:mime_type` - MIME type of the file (nil if not available)
  - `:file_size` - File size in bytes (nil if not available)

  """

  alias TelegramEx.Types

  @typedoc """
  Document struct type.
  """
  @type t :: %__MODULE__{
          file_id: String.t(),
          file_unique_id: String.t(),
          thumbnail: Types.nullable(map()),
          file_name: Types.nullable(String.t()),
          mime_type: Types.nullable(String.t()),
          file_size: Types.nullable(integer())
        }

  defstruct [
    :file_id,
    :file_unique_id,
    :thumbnail,
    :file_name,
    :mime_type,
    :file_size
  ]

  @doc """
  Converts a raw Telegram API document map to a Document struct.
  """
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      file_id: map["file_id"],
      file_unique_id: map["file_unique_id"],
      thumbnail: map["thumbnail"],
      file_name: map["file_name"],
      mime_type: map["mime_type"],
      file_size: map["file_size"]
    }
  end
end
