defmodule TelegramEx.Types.CallbackQuery do
  @moduledoc """
  Struct representing a Telegram CallbackQuery object.

  A callback query is created when a user presses an inline keyboard button.
  It contains information about the button pressed and the message it was
  attached to.

  ## Fields

  - `:id` - Unique identifier for the callback query
  - `:from` - User who triggered the callback (map with string keys)
  - `:message` - The `TelegramEx.Types.Message` the callback was attached to
  - `:inline_message_id` - Identifier of the inline message (if applicable)
  - `:chat_instance` - Global identifier for the chat
  - `:data` - Data associated with the callback button
  - `:message_thread_id` - Thread ID for forum chats (if applicable)

  """

  alias TelegramEx.Types.Message

  @typedoc """
  CallbackQuery struct type.

  Contains all fields from a Telegram callback query update.
  """
  @type t() :: %__MODULE__{
          id: String.t(),
          from: map(),
          message: Message.t() | nil,
          inline_message_id: String.t() | nil,
          chat_instance: String.t(),
          data: String.t(),
          message_thread_id: integer() | nil
        }

  defstruct [
    :id,
    :from,
    :message,
    :inline_message_id,
    :chat_instance,
    :data,
    :message_thread_id
  ]

  @doc """
  Converts a raw Telegram API callback query map to a CallbackQuery struct.
  """
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      id: map["id"],
      from: map["from"],
      message: Message.from_map(map["message"]),
      inline_message_id: map["inline_message_id"],
      chat_instance: map["chat_instance"],
      data: map["data"],
      message_thread_id: map["message_thread_id"]
    }
  end
end
