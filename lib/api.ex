defmodule TelegramEx.API do
  @moduledoc """
  HTTP wrapper around the Telegram Bot API.

  This module provides low-level functions for making HTTP requests to the
  Telegram Bot API. It handles both JSON and multipart form data requests,
  and includes error handling and logging.

  Most users should use the builder modules (`TelegramEx.Builder.*`) instead
  of calling these functions directly.

  ## Examples

      # Get updates (used internally by the polling server)
      {:ok, updates} = API.get_updates(token, 0)

      # Send a request via builder context
      ctx
      |> Map.put(:chat_id, chat_id)
      |> Map.put(:method, "sendMessage")
      |> Map.put(:payload, %{text: "Hello"})
      |> Map.put(:format, :json)
      |> API.request()

  ## Error Handling

  All functions return either `{:ok, result}` or `{:error, reason}`.
  Errors are logged automatically.
  """

  require Logger
  alias TelegramEx.Types

  @type updates :: Types.updates()
  @type request_context :: %{
          required(:chat_id) => integer(),
          required(:token) => String.t(),
          required(:method) => String.t(),
          required(:payload) => map(),
          required(:format) => :json | :multipart,
          optional(:message_thread_id) => integer()
        }

  @doc """
  Fetches updates from Telegram using long polling.

  This function is called internally by `TelegramEx.Server` to retrieve
  new messages and callbacks.

  ## Parameters

  - `token` - Bot authentication token
  - `offset` - Update ID offset for pagination (0 for first request)

  ## Returns

  - `{:ok, updates}` - List of update maps
  - `{:error, reason}` - Error atom or term

  ## Examples

      iex> API.get_updates("123456:ABC-DEF", 0)
      {:ok, [%{"update_id" => 1, "message" => %{...}}]}

      iex> API.get_updates("invalid_token", 0)
      {:error, :bad_request}
  """
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

  @doc """
  Sends a request to the Telegram Bot API.

  This is the main function used by all builder modules to send messages,
  photos, documents, and other content to Telegram.

  ## Parameters

  - `ctx` - A context map containing:
    - `:chat_id` - Target chat ID
    - `:token` - Bot authentication token
    - `:method` - Telegram API method name (e.g., "sendMessage", "sendPhoto")
    - `:payload` - Map of parameters for the API method
    - `:format` - Either `:json` or `:multipart`
    - `:message_thread_id` (optional) - Thread ID for forum chats

  ## Returns

  - `:ok` - Request succeeded
  - `{:error, reason}` - Request failed

  ## Examples

      # Send a text message
      ctx
      |> Map.put(:chat_id, 123456)
      |> Map.put(:token, "bot_token")
      |> Map.put(:method, "sendMessage")
      |> Map.put(:payload, %{text: "Hello"})
      |> Map.put(:format, :json)
      |> API.request()

      # Send a photo (multipart)
      ctx
      |> Map.put(:chat_id, 123456)
      |> Map.put(:token, "bot_token")
      |> Map.put(:method, "sendPhoto")
      |> Map.put(:payload, %{photo: file_content})
      |> Map.put(:format, :multipart)
      |> API.request()
  """
  @spec request(request_context()) :: :ok | {:error, term()}
  def request(%{chat_id: chat_id, token: token, method: method, payload: payload} = ctx) do
    payload = Map.put(payload, :chat_id, chat_id)

    payload =
      if Map.get(ctx, :message_thread_id),
        do: Map.put(payload, :message_thread_id, ctx.message_thread_id),
        else: payload

    case ctx[:format] do
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

  @doc """
  Answers a callback query from an inline keyboard button.

  This function should be called after handling a callback query to
  acknowledge it and optionally show an alert or notification to the user.

  ## Parameters

  - `token` - Bot authentication token
  - `callback` - A `TelegramEx.Types.CallbackQuery` struct

  ## Returns

  - `:ok` - Callback query answered successfully
  - `{:error, reason}` - Failed to answer callback query

  ## Examples

      def handle_callback(%{data: "confirm"} = callback, ctx) do
        API.answer_callback_query(ctx.token, callback)
        # ... send response message
      end

  ## Note

  You typically don't call this directly. Use `Message.answer_callback_query/2`
  in the builder pipeline instead.
  """
  @spec answer_callback_query(String.t(), Types.CallbackQuery.t()) :: :ok | {:error, any()}
  def answer_callback_query(token, %{id: id}) do
    Req.post("https://api.telegram.org/bot#{token}/answerCallbackQuery",
      json: %{callback_query_id: id}
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
