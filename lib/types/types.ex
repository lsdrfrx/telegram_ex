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

  @typedoc """
  A value that may be missing from the Telegram API response.

  Use this for optional Telegram object fields represented as `nil` when absent.
  """
  @type nullable(t) :: t | nil

  @doc """
  Converts raw Telegram API data to typed structs.

  Returns `nil` when the input is `nil`, converts a single map with the given
  module's `from_map/1`, and converts each item when the input is a list.
  """
  @spec map(module(), nil | map() | list(map())) :: nil | struct() | list(struct())
  def map(_module, nil), do: nil
  def map(module, input) when is_map(input), do: module.from_map(input)
  def map(module, input) when is_list(input), do: Enum.map(input, &module.from_map/1)
end
