defmodule TelegramEx.Types do
  @moduledoc """
  Common types used across the library.
  """

  @type update :: map()
  @type updates :: list(update())
  @type chat_id :: integer()
end
