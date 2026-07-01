defmodule TelegramEx.Builder.Message do
  @moduledoc """
  Builder for constructing and sending text messages.

  Functions update an effect context and `send/2` sends the final
  `sendMessage` request. See [Messages and Media](messages-and-media.md).
  """

  alias TelegramEx.API
  alias TelegramEx.Builder
  alias TelegramEx.Effect

  @type input :: map() | Effect.t()

  @doc """
  Sets the text content of the message.
  """
  @spec text(input(), String.t()) :: Effect.t()
  def text(input, text) do
    Builder.put_payload(input, :text, text)
  end

  @doc """
  Sets the text content and parse mode of the message.

  `parse_mode` is passed through to Telegram.
  """
  @spec text(input(), String.t(), String.t()) :: Effect.t()
  def text(input, text, parse_mode) do
    input
    |> Builder.put_payload(:text, text)
    |> Builder.put_payload(:parse_mode, parse_mode)
  end

  @doc """
  Adds an inline keyboard to the message.

  Inline keyboards appear directly below the message and trigger callback queries.
  """
  @spec inline_keyboard(input(), list(list(map()))) :: Effect.t()
  def inline_keyboard(input, keyboard) do
    Builder.put_payload(input, :reply_markup, %{inline_keyboard: keyboard})
  end

  @doc """
  Adds a reply keyboard to the message.

  Reply keyboards replace the user's keyboard with custom buttons.
  """
  @spec reply_keyboard(input(), list(list(String.t())), keyword()) :: Effect.t()
  def reply_keyboard(input, keyboard, opts) do
    Builder.put_payload(input, :reply_markup, Map.merge(%{keyboard: keyboard}, Map.new(opts)))
  end

  @doc """
  Removes the custom keyboard.
  """
  @spec remove_keyboard(input()) :: Effect.t()
  def remove_keyboard(input) do
    Builder.put_payload(input, :reply_markup, %{remove_keyboard: true})
  end

  @doc """
  Sends the message without notification sound.
  """
  @spec silent(input()) :: Effect.t()
  def silent(input) do
    Builder.put_payload(input, :disable_notification, true)
  end

  @doc """
  Answers a callback query from an inline keyboard button.

  This should be called when handling callback queries to acknowledge them.
  """
  @spec answer_callback_query(input(), TelegramEx.Types.CallbackQuery.t()) :: Effect.t()
  def answer_callback_query(input, callback) do
    input
    |> Effect.wrap()
    |> Effect.then(fn ctx ->
      case API.answer_callback_query(ctx.token, callback) do
        :ok -> {:ok, ctx}
        {:error, reason} -> {:error, reason}
      end
    end)
  end

  @doc """
  Sends the message to the specified chat.

  This is the final step in the builder pipeline that actually sends the message.
  """
  @spec send(input(), integer()) :: Effect.t()
  def send(input, id) do
    input
    |> Effect.wrap()
    |> Effect.then(fn ctx ->
      new_ctx =
        ctx
        |> Map.put(:chat_id, id)
        |> Map.put(:method, "sendMessage")
        |> Map.put(:format, :json)

      case API.request(new_ctx) do
        :ok -> {:ok, new_ctx}
        {:error, reason} -> {:error, reason}
      end
    end)
  end
end
