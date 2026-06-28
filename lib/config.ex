defmodule TelegramEx.Config do
  @moduledoc """
  Reads bot configuration from the application environment.

  Bot tokens are stored under the `:telegram_ex` application environment.
  See [Getting Started](getting-started.md) for configuration examples.
  """

  @doc """
  Fetches the bot token from application configuration.

  `ArgumentError` if the bot name is not configured.
  """
  @spec token(atom()) :: String.t()
  def token(name), do: Application.fetch_env!(:telegram_ex, name)
end
