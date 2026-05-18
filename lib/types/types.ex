defmodule TelegramEx.Types do
  @moduledoc """
  Common types used across the library.

  This module defines type specifications for Telegram API data structures
  and common types used throughout TelegramEx.
  """

  @typedoc """
  A raw update from the Telegram API.

  Updates are maps with string keys containing message, callback query,
  or other update types.
  """
  @type update :: map()

  @typedoc """
  A list of updates from the Telegram API.
  """
  @type updates :: list(update())

  @typedoc """
  Telegram chat identifier.

  Used to identify chats, users, and groups.
  """
  @type chat_id :: integer()
end
