defmodule TelegramEx.Types.MessageEntity do
  @moduledoc """
  Struct representing a Telegram MessageEntity object.

  Contains information about one special entity in a text message.

  ## Fields

  - `:type` - Type of the entity
  - `:offset` - Offset in UTF-16 code units to the start of the entity
  - `:length` - Length of the entity in UTF-16 code units
  - `:url` - URL opened for `"text_link"` entities (nil otherwise)
  - `:user` - User mentioned by `"text_mention"` entities (nil otherwise)
  - `:language` - Programming language for `"pre"` entities (nil otherwise)
  - `:custom_emoji_id` - Unique identifier for custom emoji entities (nil otherwise)
  - `:unix_time` - Unix timestamp for expandable blockquote entities (nil otherwise)
  - `:date_time_format` - Date format for expandable blockquote entities (nil otherwise)

  """

  alias TelegramEx.Types
  alias TelegramEx.Types.User

  @typedoc """
  MessageEntity struct type.

  Contains all fields from a Telegram message entity object.
  """
  @type t :: %__MODULE__{
          type: String.t(),
          offset: integer(),
          length: integer(),
          url: Types.nullable(String.t()),
          user: Types.nullable(User.t()),
          language: Types.nullable(String.t()),
          custom_emoji_id: Types.nullable(String.t()),
          unix_time: Types.nullable(integer()),
          date_time_format: Types.nullable(String.t())
        }

  defstruct [
    :type,
    :offset,
    :length,
    :url,
    :user,
    :language,
    :custom_emoji_id,
    :unix_time,
    :date_time_format
  ]

  @doc """
  Converts a raw Telegram API message entity map to a MessageEntity struct.
  """
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      type: map["type"],
      offset: map["offset"],
      length: map["length"],
      url: map["url"],
      language: map["language"],
      custom_emoji_id: map["custom_emoji_id"],
      unix_time: map["unix_time"],
      date_time_format: map["date_time_format"],
      user: Types.map(User, map["user"])
    }
  end
end
