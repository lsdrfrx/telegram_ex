defmodule TelegramEx.Types.ReplyParameters do
  @moduledoc """
  Struct representing Telegram ReplyParameters.

  Contains information used to reply to a message.

  ## Fields

  - `:message_id` - Identifier of the message that will be replied to
  - `:chat_id` - Target chat identifier if the replied-to message is in another chat
  - `:allow_sending_without_reply` - True to send even if the replied-to message is not found
  - `:quote` - Quoted part of the replied-to message (nil if not provided)
  - `:quote_parse_mode` - Parse mode for the quote (nil if not provided)
  - `:quote_entities` - Special entities in the quote (nil if not provided)

  """

  alias TelegramEx.Types
  alias TelegramEx.Types.MessageEntity

  @typedoc """
  ReplyParameters struct type.

  Contains all fields from Telegram reply parameters.
  """
  @type t :: %__MODULE__{
          message_id: integer(),
          chat_id: Types.nullable(integer() | String.t()),
          allow_sending_without_reply: Types.nullable(boolean()),
          quote: Types.nullable(String.t()),
          quote_parse_mode: Types.nullable(String.t()),
          quote_entities: Types.nullable(list(MessageEntity.t()))
        }

  defstruct [
    :message_id,
    :chat_id,
    :allow_sending_without_reply,
    :quote,
    :quote_parse_mode,
    :quote_entities
  ]

  @doc """
  Converts a raw Telegram API reply parameters map to a ReplyParameters struct.
  """
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      message_id: map["message_id"],
      chat_id: map["chat_id"],
      allow_sending_without_reply: map["allow_sending_without_reply"],
      quote: map["quote"],
      quote_parse_mode: map["quote_parse_mode"],
      quote_entities: Types.map(MessageEntity, map["quote_entities"])
    }
  end
end
