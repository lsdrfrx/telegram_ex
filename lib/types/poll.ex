defmodule TelegramEx.Types.PollMedia do
  @moduledoc """
  Struct representing a Telegram PollMedia object.

  At most one of the optional fields can be present in a Telegram response.
  Known related types that are not implemented as structs are kept as raw maps.
  """

  alias TelegramEx.Types
  alias TelegramEx.Types.{Audio, Document, Location, Video}

  @typedoc """
  PollMedia struct type.
  """
  @type t :: %__MODULE__{
          animation: Types.nullable(map()),
          audio: Types.nullable(Audio.t()),
          document: Types.nullable(Document.t()),
          link: Types.nullable(map()),
          live_photo: Types.nullable(map()),
          location: Types.nullable(Location.t()),
          photo: Types.nullable(list(map())),
          sticker: Types.nullable(map()),
          venue: Types.nullable(map()),
          video: Types.nullable(Video.t())
        }

  defstruct [
    :animation,
    :audio,
    :document,
    :link,
    :live_photo,
    :location,
    :photo,
    :sticker,
    :venue,
    :video
  ]

  @doc """
  Converts a raw Telegram API poll media map to a PollMedia struct.
  """
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      animation: map["animation"],
      audio: Types.map(Audio, map["audio"]),
      document: Types.map(Document, map["document"]),
      link: map["link"],
      live_photo: map["live_photo"],
      location: Types.map(Location, map["location"]),
      photo: map["photo"],
      sticker: map["sticker"],
      venue: map["venue"],
      video: Types.map(Video, map["video"])
    }
  end
end

defmodule TelegramEx.Types.PollOption do
  @moduledoc """
  Struct representing a Telegram PollOption object.

  Contains information about one answer option in a poll.
  """

  alias TelegramEx.Types
  alias TelegramEx.Types.{Chat, MessageEntity, PollMedia, User}

  @typedoc """
  PollOption struct type.
  """
  @type t :: %__MODULE__{
          persistent_id: String.t(),
          text: String.t(),
          text_entities: Types.nullable(list(MessageEntity.t())),
          media: Types.nullable(PollMedia.t()),
          voter_count: integer(),
          added_by_user: Types.nullable(User.t()),
          added_by_chat: Types.nullable(Chat.t()),
          addition_date: Types.nullable(integer())
        }

  defstruct [
    :persistent_id,
    :text,
    :text_entities,
    :media,
    :voter_count,
    :added_by_user,
    :added_by_chat,
    :addition_date
  ]

  @doc """
  Converts a raw Telegram API poll option map to a PollOption struct.
  """
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      persistent_id: map["persistent_id"],
      text: map["text"],
      text_entities: Types.map(MessageEntity, map["text_entities"]),
      media: Types.map(PollMedia, map["media"]),
      voter_count: map["voter_count"],
      added_by_user: Types.map(User, map["added_by_user"]),
      added_by_chat: Types.map(Chat, map["added_by_chat"]),
      addition_date: map["addition_date"]
    }
  end
end

defmodule TelegramEx.Types.PollAnswer do
  @moduledoc """
  Struct representing a Telegram PollAnswer object.

  Contains information about an answer of a user in a non-anonymous poll.
  """

  alias TelegramEx.Types
  alias TelegramEx.Types.{Chat, User}

  @typedoc """
  PollAnswer struct type.
  """
  @type t :: %__MODULE__{
          poll_id: String.t(),
          voter_chat: Types.nullable(Chat.t()),
          user: Types.nullable(User.t()),
          option_ids: list(integer()),
          option_persistent_ids: list(String.t())
        }

  defstruct [
    :poll_id,
    :voter_chat,
    :user,
    :option_ids,
    :option_persistent_ids
  ]

  @doc """
  Converts a raw Telegram API poll answer map to a PollAnswer struct.
  """
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      poll_id: map["poll_id"],
      voter_chat: Types.map(Chat, map["voter_chat"]),
      user: Types.map(User, map["user"]),
      option_ids: map["option_ids"],
      option_persistent_ids: map["option_persistent_ids"]
    }
  end
end

defmodule TelegramEx.Types.Poll do
  @moduledoc """
  Struct representing a Telegram Poll object.

  Contains information about a poll.

  ## Fields

  - `:id` - Unique poll identifier
  - `:question` - Poll question
  - `:question_entities` - Special entities in the question (nil if not provided)
  - `:options` - List of poll options
  - `:total_voter_count` - Total number of users that voted
  - `:is_closed` - True if the poll is closed
  - `:is_anonymous` - True if the poll is anonymous
  - `:type` - Poll type (`"regular"` or `"quiz"`)
  - `:allows_multiple_answers` - True if multiple answers are allowed
  - `:allows_revoting` - True if revoting is allowed
  - `:members_only` - True if voting is limited to long-term chat members
  - `:country_codes` - Allowed voter country codes (nil if not restricted)
  - `:correct_option_ids` - Correct option identifiers for quiz polls (nil if not available)
  - `:explanation` - Quiz explanation (nil if not available)
  - `:explanation_entities` - Special entities in the explanation (nil if not available)
  - `:explanation_media` - Media added to the quiz explanation (nil if not available)
  - `:open_period` - Poll active period in seconds (nil if not available)
  - `:close_date` - Poll close date as Unix timestamp (nil if not available)
  - `:description` - Poll description (nil if not available)
  - `:description_entities` - Special entities in the description (nil if not available)
  - `:media` - Media added to the poll description (nil if not available)

  """

  alias TelegramEx.Types
  alias TelegramEx.Types.{MessageEntity, PollMedia, PollOption}

  @typedoc """
  Poll struct type.
  """
  @type t :: %__MODULE__{
          id: String.t(),
          question: String.t(),
          question_entities: Types.nullable(list(MessageEntity.t())),
          options: list(PollOption.t()),
          total_voter_count: integer(),
          is_closed: boolean(),
          is_anonymous: boolean(),
          type: String.t(),
          allows_multiple_answers: boolean(),
          allows_revoting: boolean(),
          members_only: boolean(),
          country_codes: Types.nullable(list(String.t())),
          correct_option_ids: Types.nullable(list(integer())),
          explanation: Types.nullable(String.t()),
          explanation_entities: Types.nullable(list(MessageEntity.t())),
          explanation_media: Types.nullable(PollMedia.t()),
          open_period: Types.nullable(integer()),
          close_date: Types.nullable(integer()),
          description: Types.nullable(String.t()),
          description_entities: Types.nullable(list(MessageEntity.t())),
          media: Types.nullable(PollMedia.t())
        }

  defstruct [
    :id,
    :question,
    :question_entities,
    :options,
    :total_voter_count,
    :is_closed,
    :is_anonymous,
    :type,
    :allows_multiple_answers,
    :allows_revoting,
    :members_only,
    :country_codes,
    :correct_option_ids,
    :explanation,
    :explanation_entities,
    :explanation_media,
    :open_period,
    :close_date,
    :description,
    :description_entities,
    :media
  ]

  @doc """
  Converts a raw Telegram API poll map to a Poll struct.
  """
  @spec from_map(map()) :: t()
  def from_map(map) do
    %__MODULE__{
      id: map["id"],
      question: map["question"],
      question_entities: Types.map(MessageEntity, map["question_entities"]),
      options: Types.map(PollOption, map["options"]),
      total_voter_count: map["total_voter_count"],
      is_closed: map["is_closed"],
      is_anonymous: map["is_anonymous"],
      type: map["type"],
      allows_multiple_answers: map["allows_multiple_answers"],
      allows_revoting: map["allows_revoting"],
      members_only: map["members_only"],
      country_codes: map["country_codes"],
      correct_option_ids: map["correct_option_ids"],
      explanation: map["explanation"],
      explanation_entities: Types.map(MessageEntity, map["explanation_entities"]),
      explanation_media: Types.map(PollMedia, map["explanation_media"]),
      open_period: map["open_period"],
      close_date: map["close_date"],
      description: map["description"],
      description_entities: Types.map(MessageEntity, map["description_entities"]),
      media: Types.map(PollMedia, map["media"])
    }
  end
end
