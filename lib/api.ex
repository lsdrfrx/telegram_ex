defmodule TelegramEx.API do
  @moduledoc """
  HTTP wrapper around the Telegram Bot API.

  Most application code should use builder modules instead of calling this
  module directly. See [Messages and Media](messages-and-media.md).
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

  defp client do
    Application.get_env(:telegram_ex, :req_client) ||
      Req.new()
      |> ReqProxy.attach()
      |> tap(&Application.put_env(:telegram_ex, :req_client, &1))
  end

  @doc """
  Fetches updates from Telegram using long polling.

  This function is called internally by `TelegramEx.Server` to retrieve
  new messages and callbacks.
  """
  @spec get_updates(String.t(), integer()) :: {:ok, updates()} | {:error, any()}
  def get_updates(token, offset) do
    case client()
         |> Req.get(
           url: "https://api.telegram.org/bot#{token}/getUpdates",
           params: [offset: offset]
         ) do
      {:ok, %{status: 200, body: %{"ok" => true, "result" => updates}}} ->
        {:ok, updates}

      {:ok, %{body: %{"description" => reason} = body}} ->
        Logger.error(reason)
        {:error, TelegramEx.Error.from_body(body)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Sends a request to the Telegram Bot API.

  Expects a builder context with `:chat_id`, `:token`, `:method`, `:payload`,
  and `:format`.
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
        client()
        |> Req.post(url: "https://api.telegram.org/bot#{token}/#{method}", json: payload)
        |> handle_response()

      :multipart ->
        client()
        |> Req.post(
          url: "https://api.telegram.org/bot#{token}/#{method}",
          form_multipart: payload
        )
        |> handle_response()

      _ ->
        {:error, :invalid_format}
    end
  end

  @doc """
  Answers a callback query from an inline keyboard button.

  This function should be called after handling a callback query to
  acknowledge it and optionally show an alert or notification to the user.

  Most code should call `TelegramEx.Builder.Message.answer_callback_query/2`
  in a builder pipeline.
  """
  @spec answer_callback_query(String.t(), Types.CallbackQuery.t()) :: :ok | {:error, any()}
  def answer_callback_query(token, %{id: id}) do
    client()
    |> Req.post(
      url: "https://api.telegram.org/bot#{token}/answerCallbackQuery",
      json: %{callback_query_id: id}
    )
    |> handle_response()
  end

  def set_my_commands(commands, token) when is_list(commands) do
    client()
    |> Req.post(
      url: "https://api.telegram.org/bot#{token}/setMyCommands",
      json: %{commands: commands}
    )
    |> handle_response()
  end

  defp handle_response({:ok, %{status: 200}}) do
    :ok
  end

  defp handle_response({:ok, %{body: %{"description" => reason} = body}}) do
    Logger.error(reason)
    {:error, TelegramEx.Error.from_body(body)}
  end

  defp handle_response({:ok, response}) do
    Logger.error("Unknown error: #{inspect(response)}")
    {:error, :unknown_error}
  end

  defp handle_response({:error, reason}) do
    {:error, reason}
  end
end
