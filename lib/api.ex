defmodule TelegramEx.API do
  @moduledoc """
  HTTP wrapper around the Telegram Bot API.

      API.send_message(token, %{chat_id: 123, text: "Hi"})
      API.send_photo(token, %{chat_id: 123, photo: "https://..."})
  """

  require Logger
  alias TelegramEx.Types

  @type updates :: Types.updates()

  @spec get_updates(String.t(), integer()) :: {:ok, updates()} | {:error, any()}
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

  @spec send_message(String.t(), map()) :: :ok | {:error, any()}
  def send_message(token, message) do
    Req.post("https://api.telegram.org/bot#{token}/sendMessage", json: message)
    |> handle_response()
  end

  @spec send_photo(String.t(), map()) :: :ok | {:error, any()}
  def send_photo(token, photo) do
    Req.post("https://api.telegram.org/bot#{token}/sendPhoto", form_multipart: photo)
    |> handle_response()
  end

  def send_sticker(token, sticker) do
    Req.post("https://api.telegram.org/bot#{token}/sendSticker", form_multipart: sticker)
    |> handle_response()
  end

  def send_location(token, location) do
    Req.post("https://api.telegram.org/bot#{token}/sendLocation", json: location)
    |> handle_response()
  end

  def send_video(token, video) do
    Req.post("https://api.telegram.org/bot#{token}/sendVideo", form_multipart: video)
    |> handle_response()
  end

  @spec answer_callback_query(String.t(), String.t()) :: :ok | {:error, any()}
  def answer_callback_query(token, callback) do
    Req.post("https://api.telegram.org/bot#{token}/answerCallbackQuery",
      json: %{callback_query_id: callback}
    )
    |> handle_response()
  end

  @spec send_document(String.t(), map()) :: :ok | {:error, any()}
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
