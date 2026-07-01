defmodule TelegramEx.Builder.Poll do
  @moduledoc """
  Builder for poll and quiz payloads.

  Builds `sendPoll` payloads for regular polls and quizzes. See
  [Messages and Media](messages-and-media.md).
  """

  alias TelegramEx.API
  alias TelegramEx.Builder
  alias TelegramEx.Effect

  @type input :: map() | Effect.t()

  @spec poll(input(), String.t(), list(String.t())) :: Effect.t()
  def poll(input, question, options) do
    input
    |> Builder.put_payload(:question, question)
    |> Builder.put_payload(:options, options)
    |> Builder.put_payload(:type, "regular")
  end

  @spec quiz(input(), String.t(), list(String.t()), integer()) :: Effect.t()
  def quiz(input, question, options, correct_option_id) do
    input
    |> Builder.put_payload(:question, question)
    |> Builder.put_payload(:options, options)
    |> Builder.put_payload(:type, "quiz")
    |> Builder.put_payload(:correct_option_id, correct_option_id)
  end

  @spec anonymous(input(), boolean()) :: Effect.t()
  def anonymous(input, boolean) do
    Builder.put_payload(input, :is_anonymous, boolean)
  end

  @spec multiple_answers(input(), boolean()) :: Effect.t()
  def multiple_answers(input, boolean) do
    Builder.put_payload(input, :allows_multiple_answers, boolean)
  end

  @spec explanation(input(), String.t()) :: Effect.t()
  def explanation(input, text) do
    Builder.put_payload(input, :explanation, text)
  end

  @spec explanation(input(), String.t(), String.t()) :: Effect.t()
  def explanation(input, text, parse_mode) do
    input
    |> Builder.put_payload(:explanation, text)
    |> Builder.put_payload(:explanation_parse_mode, parse_mode)
  end

  @spec open_period(input(), integer()) :: Effect.t()
  def open_period(input, seconds) do
    Builder.put_payload(input, :open_period, seconds)
  end

  @spec close_date(input(), integer()) :: Effect.t()
  def close_date(input, timestamp) do
    Builder.put_payload(input, :close_date, timestamp)
  end

  @spec silent(input()) :: Effect.t()
  def silent(input) do
    Builder.put_payload(input, :disable_notification, true)
  end

  @spec send(input(), integer()) :: Effect.t()
  def send(input, id) do
    input
    |> Effect.wrap()
    |> Effect.then(fn ctx ->
      new_ctx =
        ctx
        |> Map.put(:chat_id, id)
        |> Map.put(:method, "sendPoll")
        |> Map.put(:format, :json)

      case API.request(new_ctx) do
        :ok -> {:ok, new_ctx}
        {:error, reason} -> {:error, reason}
      end
    end)
  end
end
