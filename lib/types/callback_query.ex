defmodule TelegramEx.Types.CallbackQuery do
  @moduledoc "Struct representing a Telegram CallbackQuery object."

  alias TelegramEx.Types.Message

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
