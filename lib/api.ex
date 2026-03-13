defmodule TelegramEx.API do
  require Logger

  def get_updates(token, offset) do
    case Req.get("https://api.telegram.org/bot#{token}/getUpdates?offset=#{offset}") do
      {:ok, %{status: 200, body: %{"ok" => true, "result" => updates}}} ->
        {:ok, updates}

      {:ok, %{body: %{"description" => reason}}} ->
        Logger.error(reason)
        {:error, :bad_request}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def send_message(token, message) do
    Req.post("https://api.telegram.org/bot#{token}/sendMessage", json: message)
    |> handle_response()
  end

  def send_photo(token, photo) do
    Req.post("https://api.telegram.org/bot#{token}/sendPhoto", form_multipart: photo)
    |> handle_response()
  end

  def answer_callback_query(token, callback) do
    Req.post("https://api.telegram.org/bot#{token}/answerCallbackQuery",
           json: %{callback_query_id: callback}
         )
    |> handle_response()
  end

  def send_document(token, document) do
    Req.post("https://api.telegram.org/bot#{token}/sendDocument",
           form_multipart: document
         )
    |> handle_response()
  end

  defp handle_response({:ok, %{status: 200}}) do
    :ok
  end

  defp handle_response({:ok, %{body: %{"description" => reason}}}) do
    Logger.error(reason)
    {:error, :bad_request}
  end

  defp handle_response({:ok, response}) do
    Logger.error("Unknown error: #{inspect(response)}")
    {:error, :unknown_error}
  end

  defp handle_response({:error, reason}) do
    {:error, reason}
  end
end
