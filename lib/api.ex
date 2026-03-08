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
    case Req.post("https://api.telegram.org/bot#{token}/sendMessage", json: message) do
      {:ok, %{status: 200}} ->
        :ok

      {:ok, %{body: %{"description" => reason}}} ->
        Logger.error(reason)
        {:error, :bad_request}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def send_photo(token, photo) do
    case Req.post("https://api.telegram.org/bot#{token}/sendPhoto", form_multipart: photo) do
      {:ok, %{status: 200}} ->
        :ok

      {:ok, %{body: %{"description" => reason}}} ->
        Logger.error(reason)
        {:error, :bad_request}

      {:error, reason} ->
        {:error, reason}
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
        {:error, :bad_request}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def send_document(token, document) do
    case Req.post("https://api.telegram.org/bot#{token}/sendDocument",
           form_multipart: document
         ) do
      {:ok, %{status: 200}} ->
        Logger.info("sent")
        :ok

      {:ok, %{body: %{"description" => reason}}} ->
        Logger.error(reason)
        {:error, :bad_request}

      {:ok, response} ->
        Logger.error("Unknown error: #{inspect(response)}")

      {:error, reason} ->
        Logger.error(reason)
        {:error, reason}
    end
  end
end
