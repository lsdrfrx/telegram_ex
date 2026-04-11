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

  def request(token, method, payload, opts \\ [format: :json]) do
    case opts[:format] do
      :json ->
        Req.post("https://api.telegram.org/bot#{token}/#{method}", json: payload)
        |> handle_response()

      :multipart ->
        Req.post("https://api.telegram.org/bot#{token}/#{method}", form_multipart: payload)
        |> handle_response()

      _ ->
        {:error, :invalid_format}
    end
  end

  @spec answer_callback_query(String.t(), String.t()) :: :ok | {:error, any()}
  def answer_callback_query(token, callback) do
    Req.post("https://api.telegram.org/bot#{token}/answerCallbackQuery",
      json: %{callback_query_id: callback}
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
