defmodule TelegramEx.API do
  require Logger

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

  def send_message(token, message) do
    case Req.post("https://api.telegram.org/bot#{token}/sendMessage", json: message) do
      {:ok, %{status: 200}} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def answer_callback_query(token, callback) do
    case Req.post("https://api.telegram.org/bot#{token}/answerCallbackQuery",
           json: %{callback_query_id: callback}
         ) do
      {:ok, %{status: 200}} ->
        :ok

      {:ok, %{body: %{"description" => reason}}} ->
        Logger.error(reason)
        {:error, :unknown}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
