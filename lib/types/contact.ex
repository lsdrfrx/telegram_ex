defmodule TelegramEx.Types.Contact do
  @moduledoc """
  Struct representing a Telegram Contact object.

  Contains information about a phone contact.

  ## Fields

  - `:phone_number` - Contact's phone number
  - `:first_name` - Contact's first name
  - `:last_name` - Contact's last name (nil if not available)
  - `:user_id` - Contact's Telegram user identifier (nil if not available)
  - `:vcard` - Additional vCard data (nil if not available)

  """

  alias TelegramEx.Types

  @typedoc """
  Contact struct type.
  """
  @type t :: %__MODULE__{
          phone_number: String.t(),
          first_name: String.t(),
          last_name: Types.nullable(String.t()),
          user_id: Types.nullable(integer()),
          vcard: Types.nullable(String.t())
        }

  defstruct [
    :phone_number,
    :first_name,
    :last_name,
    :user_id,
    :vcard
  ]

  @doc """
  Converts a raw Telegram API contact map to a Contact struct.
  """
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      phone_number: map["phone_number"],
      first_name: map["first_name"],
      last_name: map["last_name"],
      user_id: map["user_id"],
      vcard: map["vcard"]
    }
  end
end
