defmodule TelegramEx.Types.Message do
  @moduledoc """
  Struct representing a Telegram Message object.

  Contains incoming message fields used by handlers.

  ##Fields

  - `:message_id` - Unique message identifier
  - `:from` - Sender information (map with string keys)
  - `:chat` - Chat information (map with string keys)
  - `:date` - Message date as Unix timestamp
  - `:text` - Message text content (nil if not a text message)
  - `:photo` - List of photo sizes (nil if no photo)
  - `:document` - Document attachment (nil if no document)
  - `:sticker` - Sticker (nil if no sticker)
  - `:video` - Video (nil if no video)
  - `:audio` - Audio attachment (nil if no audio)
  - `:voice` - Voice message (nil if no voice)
  - `:contact` - Contact attachment (nil if no contact)
  - `:location` - Location attachment (nil if no location)
  - `:poll` - Poll attachment (nil if no poll)
  - `:caption` - Caption for media (nil if no caption)
  - `:message_thread_id` - Thread ID for forum chats (nil if not in a thread)

  """

  alias TelegramEx.Types
  alias TelegramEx.Types.{Audio, Chat, Contact, Document, Location, Message, Poll, Video}

  @typedoc """
  Message struct type.

  Contains all fields from a Telegram message update.
  """
  @type t :: %__MODULE__{
          message_id: integer(),
          from: map(),
          chat: Chat.t(),
          date: integer(),
          text: Types.nullable(String.t()),
          photo: Types.nullable(list(map())),
          document: Types.nullable(Document.t()),
          sticker: Types.nullable(map()),
          video: Types.nullable(Video.t()),
          voice: Types.nullable(map()),
          audio: Types.nullable(Audio.t()),
          contact: Types.nullable(Contact.t()),
          location: Types.nullable(Location.t()),
          poll: Types.nullable(Poll.t()),
          caption: Types.nullable(String.t()),
          message_thread_id: Types.nullable(integer()),
          reply: Types.nullable(t())
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
    :audio,
    :voice,
    :contact,
    :location,
    :poll,
    :caption,
    :message_thread_id,
    :reply
  ]

  @doc """
  Converts a raw Telegram API message map to a Message struct.
  """
  @spec from_map(nil) :: nil
  @spec from_map(map()) :: t()
  def from_map(nil), do: nil

  def from_map(map) do
    %__MODULE__{
      message_id: map["message_id"],
      message_thread_id: map["message_thread_id"],
      from: map["from"],
      date: map["date"],
      text: map["text"] || nil,
      photo: map["photo"],
      document: Types.map(Document, map["document"]),
      sticker: map["sticker"],
      video: Types.map(Video, map["video"]),
      audio: Types.map(Audio, map["audio"]),
      voice: map["voice"],
      contact: Types.map(Contact, map["contact"]),
      location: Types.map(Location, map["location"]),
      poll: Types.map(Poll, map["poll"]),
      caption: map["caption"],
      chat: Types.map(Chat, map["chat"]),
      reply: Types.map(Message, map["reply_to_message"])
    }
  end
end
