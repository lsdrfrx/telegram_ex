defmodule TelegramEx.Types.Message do
  @moduledoc "Struct representing a Telegram Message object."

  @type t :: %__MODULE__{
          message_id: integer(),
          from: map(),
          chat: map(),
          date: integer(),
          text: String.t() | nil,
          photo: list(map()) | nil,
          document: map() | nil,
          sticker: map() | nil,
          video: map() | nil,
          voice: map() | nil,
          caption: String.t() | nil,
          message_thread_id: integer() | nil
        }

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
    :caption,
    :message_thread_id
  ]

  def from_map(map) do
    %__MODULE__{
      message_id: map["message_id"],
      message_thread_id: map["message_thread_id"],
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
