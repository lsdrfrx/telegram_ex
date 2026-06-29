defmodule TelegramEx.Builder.Message do
  @moduledoc """
  Builder for constructing and sending text messages.

  Functions update the builder context and `send/2` sends the final
  `sendMessage` request. See [Messages and Media](messages-and-media.md).
  """

  alias TelegramEx.API

  @doc """
  Sets the text content of the message.
  """
  @spec text(map(), String.t()) :: map()
  def text(ctx, text) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:text, text)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sets the text content and parse mode of the message.

  `parse_mode` is passed through to Telegram.
  """
  @spec text(map(), String.t(), String.t()) :: map()
  def text(ctx, text, parse_mode) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:text, text)
    |> Map.put(:parse_mode, parse_mode)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Adds an inline keyboard to the message.

  Inline keyboards appear directly below the message and trigger callback queries.
  """
  @spec inline_keyboard(map(), list(list(map()))) :: map()
  def inline_keyboard(ctx, keyboard) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:reply_markup, %{inline_keyboard: keyboard})
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Adds a reply keyboard to the message.

  Reply keyboards replace the user's keyboard with custom buttons.
  """
  @spec reply_keyboard(map(), list(list(String.t())), keyword()) :: map()
  def reply_keyboard(ctx, keyboard, opts) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:reply_markup, Map.merge(%{keyboard: keyboard}, Map.new(opts)))
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Removes the custom keyboard.
  """
  @spec remove_keyboard(map()) :: map()
  def remove_keyboard(ctx) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:reply_markup, %{remove_keyboard: true})
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sends the message without notification sound.
  """
  @spec silent(map()) :: map()
  def silent(ctx) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:disable_notification, true)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Answers a callback query from an inline keyboard button.

  This should be called when handling callback queries to acknowledge them.
  """
  @spec answer_callback_query(map(), TelegramEx.Types.CallbackQuery.t()) :: map()
  def answer_callback_query(ctx, callback) do
    API.answer_callback_query(Process.get(:token), callback)
    ctx
  end

  @doc """
  Sends the message to the specified chat.

  This is the final step in the builder pipeline that actually sends the message.
  """
  @spec send(map(), integer()) :: :ok | {:error, term()}
  def send(ctx, id) do
    ctx
    |> Map.put(:chat_id, id)
    |> Map.put(:method, "sendMessage")
    |> Map.put(:format, :json)
    |> API.request()
  end
end
