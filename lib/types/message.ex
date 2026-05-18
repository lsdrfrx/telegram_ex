defmodule TelegramEx.Types.Message do
  @moduledoc """
  Struct representing a Telegram Message object.

  This struct contains all the information about an incoming message,
  including text, media attachments, sender information, and chat details.

  ## Fields

  - `:message_id` - Unique message identifier
  - `:from` - Sender information (map with string keys)
  - `:chat` - Chat information (map with string keys)
  - `:date` - Message date as Unix timestamp
  - `:text` - Message text content (nil if not a text message)
  - `:photo` - List of photo sizes (nil if no photo)
  - `:document` - Document attachment (nil if no document)
  - `:sticker` - Sticker (nil if no sticker)
  - `:video` - Video (nil if no video)
  - `:voice` - Voice message (nil if no voice)
  - `:caption` - Caption for media (nil if no caption)
  - `:message_thread_id` - Thread ID for forum chats (nil if not in a thread)

  ## Examples

      def handle_message(%Message{text: text, chat: chat}, ctx) do
        # Pattern match on message fields
        ctx
        |> Message.text("You said: \#{text}")
        |> Message.send(chat["id"])
      end
  """

  @typedoc """
  Message struct type.

  Contains all fields from a Telegram message update.
  """
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

  @doc """
  Converts a raw Telegram API message map to a Message struct.

  ## Parameters

  - `map` - Raw message map from Telegram API

  ## Returns

  A `TelegramEx.Types.Message` struct.

  ## Examples

      iex> Message.from_map(%{"message_id" => 1, "text" => "Hello", ...})
      %TelegramEx.Types.Message{message_id: 1, text: "Hello", ...}
  """
  @spec from_map(map()) :: t()
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
