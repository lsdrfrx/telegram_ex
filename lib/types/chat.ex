defmodule TelegramEx.Types.Chat do
  @moduledoc """
  Struct representing a Telegram Chat object.

  Contains information about a private chat, group, supergroup, channel,
  or direct messages chat.

  ## Fields

  - `:id` - Unique identifier for the chat
  - `:type` - Type of chat (`"private"`, `"group"`, `"supergroup"`, `"channel"`, or `"direct_messages"`)
  - `:title` - Title for supergroups, channels and group chats (nil if not applicable)
  - `:username` - Username for private chats, supergroups and channels (nil if not available)
  - `:first_name` - First name of the other party in a private chat (nil if not applicable)
  - `:last_name` - Last name of the other party in a private chat (nil if not available)
  - `:is_forum` - True if the supergroup chat is a forum (nil otherwise)
  - `:is_direct_messages` - True if the chat is a direct messages chat (nil otherwise)

  """

  @typedoc """
  Chat struct type.

  Contains all fields from a Telegram chat object.
  """
  @type t :: %__MODULE__{
          id: integer(),
          type: String.t(),
          title: String.t() | nil,
          username: String.t() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          is_forum: true | nil,
          is_direct_messages: true | nil
        }

  defstruct [
    :id,
    :type,
    :title,
    :username,
    :first_name,
    :last_name,
    :is_forum,
    :is_direct_messages
  ]

  @doc """
  Converts a raw Telegram API chat map to a Chat struct.
  """
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      id: map["id"],
      type: map["type"],
      title: map["title"],
      username: map["username"],
      first_name: map["first_name"],
      last_name: map["last_name"],
      is_forum: map["is_forum"],
      is_direct_messages: map["is_direct_messages"]
    }
  end
end
