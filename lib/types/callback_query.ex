defmodule TelegramEx.Types.CallbackQuery do
  defstruct [
    :id,
    :from,
    :message,
    :inline_message_id,
    :chat_instance,
    :data
  ]

  def from_map(map) do
    %__MODULE__{
      id: map["id"],
      from: map["from"],
      message: TelegramEx.Types.Message.from_map(map["message"]),
      inline_message_id: map["inline_message_id"],
      chat_instance: map["chat_instance"],
      data: map["data"]
    }
  end
end
