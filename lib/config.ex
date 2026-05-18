defmodule TelegramEx.Config do
  @moduledoc """
  Reads bot configuration from the application environment.

  This module provides utilities for accessing bot tokens and other
  configuration values stored in the application environment under
  the `:telegram_ex` key.

  ## Configuration

  Bot tokens should be configured in `config/runtime.exs`:

      # config/runtime.exs
      import Config

      config :telegram_ex,
        my_bot: System.fetch_env!("MY_BOT_TELEGRAM_TOKEN"),
        another_bot: System.fetch_env!("ANOTHER_BOT_TOKEN")

  ## Example

      Config.token(:my_bot)  # => "123456:ABC-token"
  """

  @doc """
  Fetches the bot token from application configuration.

  ## Parameters

  - `name` - The bot name (atom) used when defining the bot with `use TelegramEx`

  ## Returns

  The bot token as a string.

  ## Raises

  `ArgumentError` if the bot name is not configured.

  ## Examples

      iex> Config.token(:my_bot)
      "123456789:ABCdefGHIjklMNOpqrsTUVwxyz"

      iex> Config.token(:nonexistent_bot)
      ** (ArgumentError) could not fetch application environment :nonexistent_bot for application :telegram_ex
  """
  @spec token(atom()) :: String.t()
  def token(name), do: Application.fetch_env!(:telegram_ex, name)
end
