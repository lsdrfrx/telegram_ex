defmodule TelegramEx.Types.Message do
  @moduledoc "Struct representing a Telegram Message object."

  defstruct [
    :message_id,
    :from,
    :chat,
    :date,
    :text,
    :photo,
    :document,
    :sticker,
    :video,
    :voice,
    :caption
  ]

  def from_map(map) do
    %__MODULE__{
      message_id: map["message_id"],
      from: map["from"],
      chat: map["chat"],
      date: map["date"],
      text: Map.get(map, "text", ""),
      photo: map["photo"],
      document: map["document"],
      sticker: map["sticker"],
      video: map["video"],
      voice: map["voice"],
      caption: map["caption"]
    }
  end
end
