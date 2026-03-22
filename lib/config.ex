defmodule TelegramEx.Config do
  def token(name), do: Application.fetch_env!(:telegram_ex, name)
end
