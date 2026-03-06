defmodule TelegramEx.API do
  def get_updates(token, offset) do
    case Req.get("https://api.telegram.org/bot#{token}/getUpdates?offset=#{offset}") do
      {:ok, %{status: 200, body: %{"ok" => true, "result" => updates}}} ->
        {:ok, updates}

      {:ok, _} ->
        {:error, :unknown_error}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def send_message(token, to, text) do
    case Req.get("https://api.telegram.org/bot#{token}/sendMessage?chat_id=#{to}&text=#{text}") do
      {:ok, %{status: 200}} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
