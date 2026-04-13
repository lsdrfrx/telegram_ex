defmodule TelegramEx.Builder.Message do
  @moduledoc """
  Builder for text message payloads.

      Message.text("Hello", "Markdown")
      |> Message.inline_keyboard([[%{text: "OK", callback_data: "ok"}]])
      |> Message.send(chat_id)
  """

  alias TelegramEx.API

  def text(ctx, text) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:text, text)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def text(ctx, text, parse_mode) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:text, text)
    |> Map.put(:parse_mode, parse_mode)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def inline_keyboard(ctx, keyboard) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:reply_markup, %{inline_keyboard: keyboard})
    |> then(&Map.put(ctx, :payload, &1))
  end

  def reply_keyboard(ctx, keyboard, opts) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:reply_markup, Map.merge(%{keyboard: keyboard}, Map.new(opts)))
    |> then(&Map.put(ctx, :payload, &1))
  end

  def remove_keyboard(ctx) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:reply_markup, %{remove_keyboard: true})
    |> then(&Map.put(ctx, :payload, &1))
  end

  def silent(ctx) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:disable_notification, true)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def answer_callback_query(ctx, callback) do
    API.answer_callback_query(Process.get(:token), callback)
    ctx
  end

  def send(ctx, id) do
    ctx
    |> Map.put(:chat_id, id)
    |> Map.put(:method, "sendMessage")
    |> Map.put(:format, :json)
    |> API.request()
  end
end
