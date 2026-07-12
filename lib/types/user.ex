defmodule TelegramEx.Types.User do
  @moduledoc """
  Struct representing a Telegram User object.

  Contains information about a Telegram user or bot.

  ## Fields

  - `:id` - Unique identifier for the user or bot
  - `:is_bot` - True if this user is a bot
  - `:first_name` - User's or bot's first name (nil if not available)
  - `:last_name` - User's or bot's last name (nil if not available)
  - `:username` - User's or bot's username (nil if not available)
  - `:language_code` - IETF language tag of the user's language (nil if not available)
  - `:is_premium` - True if this user is a Telegram Premium user (nil otherwise)

  """

  alias TelegramEx.Types

  @typedoc """
  User struct type.

  Contains all fields from a Telegram user object.
  """
  @type t :: %__MODULE__{
          id: integer(),
          is_bot: boolean(),
          first_name: Types.nullable(String.t()),
          last_name: Types.nullable(String.t()),
          username: Types.nullable(String.t()),
          language_code: Types.nullable(String.t()),
          is_premium: Types.nullable(true)
        }

  defstruct [
    :id,
    :is_bot,
    :first_name,
    :last_name,
    :username,
    :language_code,
    :is_premium
  ]

  @doc """
  Converts a raw Telegram API user map to a User struct.
  """
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      id: map["id"],
      is_bot: map["is_bot"],
      first_name: map["first_name"],
      last_name: map["last_name"],
      username: map["username"],
      language_code: map["language_code"],
      is_premium: map["is_premium"]
    }
  end
end
