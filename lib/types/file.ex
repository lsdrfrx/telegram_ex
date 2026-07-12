defmodule TelegramEx.Types.File do
  @moduledoc """
  Struct representing a Telegram File object.

  Contains information about a file ready to be downloaded.

  ## Fields

  - `:file_id` - Identifier for this file
  - `:file_unique_id` - Stable unique identifier for this file
  - `:file_size` - File size in bytes (nil if not available)
  - `:file_path` - File path for download (nil if not available)

  """

  alias TelegramEx.Types

  @typedoc """
  File struct type.
  """
  @type t :: %__MODULE__{
          file_id: String.t(),
          file_unique_id: String.t(),
          file_size: Types.nullable(integer()),
          file_path: Types.nullable(String.t())
        }

  defstruct [
    :file_id,
    :file_unique_id,
    :file_size,
    :file_path
  ]

  @doc """
  Converts a raw Telegram API file map to a File struct.
  """
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      file_id: map["file_id"],
      file_unique_id: map["file_unique_id"],
      file_size: map["file_size"],
      file_path: map["file_path"]
    }
  end
end
