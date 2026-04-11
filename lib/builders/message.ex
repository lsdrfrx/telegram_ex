defmodule TelegramEx.Builder.Message do
  @moduledoc """
  Builder for text message payloads.

      Message.text("Hello", "Markdown")
      |> Message.inline_keyboard([[%{text: "OK", callback_data: "ok"}]])
      |> Message.send(chat_id)
  """

  alias TelegramEx.API

  def text(text) do
    %{text: text}
  end

  def text(text, parse_mode) do
    %{text: text, parse_mode: parse_mode}
  end

  def inline_keyboard(message, keyboard) do
    Map.put(message, :reply_markup, %{inline_keyboard: keyboard})
  end

  def reply_keyboard(message, keyboard, opts) do
    message
    |> Map.put(:reply_markup, Map.merge(%{keyboard: keyboard}, Map.new(opts)))
  end

  def remove_keyboard(message) do
    Map.put(message, :reply_markup, %{remove_keyboard: true})
  end

  def silent(message) do
    Map.put(message, :disable_notification, true)
  end

  def answer_callback_query(message, callback) do
    API.answer_callback_query(Process.get(:token), callback)
    message
  end

  def send(message, id) do
    message
    |> Map.put(:chat_id, id)
    |> then(&API.request(Process.get(:token), "sendMessage", &1))
  end
end
