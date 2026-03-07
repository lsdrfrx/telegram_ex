defmodule TelegramEx.Builder.Message do
  alias TelegramEx.Config

  def new(id) do
    %{chat_id: id}
  end

  def text(message, text) do
    Map.put(message, :text, text)
  end

  def text(message, text, parse_mode) do
    message
    |> Map.put(:text, text)
    |> Map.put(:parse_mode, parse_mode)
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
    TelegramEx.API.answer_callback_query(Config.token(), callback)
    message
  end

  def send(message) do
    TelegramEx.API.send_message(Config.token(), message)
  end
end
