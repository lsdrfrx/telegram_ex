defmodule TelegramEx.Config do
  def validate do
    with {:ok, _} <- Application.fetch_env(:telegram_ex, :token) do
      :ok
    else
      :error ->
        IO.inspect("ERROR")
    end
  end

  def token, do: Application.fetch_env!(:telegram_ex, :token)
end
