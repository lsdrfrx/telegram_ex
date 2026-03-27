defmodule TelegramEx.Config do
  @moduledoc """
  Reads bot configuration from the application environment.

      # config/config.exs
      config :telegram_ex, my_bot: "123456:ABC-token"

      Config.token(:my_bot)  # => "123456:ABC-token"
  """

  def token(name), do: Application.fetch_env!(:telegram_ex, name)
end
