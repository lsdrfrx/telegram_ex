defmodule TelegramEx.Builder.Poll do
  @moduledoc """
  Builder for poll and quiz payloads.

  Builds `sendPoll` payloads for regular polls and quizzes. See
  [Messages and Media](messages-and-media.md).
  """

  alias TelegramEx.API

  def poll(ctx, question, options) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:question, question)
    |> Map.put(:options, options)
    |> Map.put(:type, "regular")
    |> then(&Map.put(ctx, :payload, &1))
  end

  def quiz(ctx, question, options, correct_option_id) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:question, question)
    |> Map.put(:options, options)
    |> Map.put(:type, "quiz")
    |> Map.put(:correct_option_id, correct_option_id)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def anonymous(ctx, boolean) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:is_anonymous, boolean)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def multiple_answers(ctx, boolean) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:allows_multiple_answers, boolean)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def explanation(ctx, text) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:explanation, text)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def explanation(ctx, text, parse_mode) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:explanation, text)
    |> Map.put(:explanation_parse_mode, parse_mode)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def open_period(ctx, seconds) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:open_period, seconds)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def close_date(ctx, timestamp) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:close_date, timestamp)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def silent(ctx) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:disable_notification, true)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def send(ctx, id) do
    ctx
    |> Map.put(:chat_id, id)
    |> Map.put(:method, "sendPoll")
    |> Map.put(:format, :json)
    |> API.request()
  end
end
