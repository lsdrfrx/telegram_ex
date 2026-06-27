defmodule TelegramEx.Error do
  @moduledoc """
  Struct representing an error returned by the Telegram Bot API.

  When a request fails, Telegram responds with `"ok" => false` and a body
  describing the problem. This struct captures that response in a structured
  form so callers can inspect the error code, description, and any retry hint
  instead of receiving a single opaque `:bad_request` atom.

  ## Fields

  - `:type` - Source of the error (`:telegram` for API errors)
  - `:code` - Numeric error code from `error_code` (nil if absent)
  - `:reason` - Optional atom describing the error (nil unless provided)
  - `:description` - Human-readable description from the API
  - `:retry_after` - Seconds to wait before retrying, from `parameters.retry_after` (nil if absent)
  - `:raw` - The raw response body, for callers that need the full payload

  ## Examples

      case API.request(ctx) do
        :ok ->
          :ok

        {:error, %TelegramEx.Error{code: 429, retry_after: seconds}} ->
          Process.sleep(seconds * 1000)
      end
  """

  @typedoc """
  Error struct type.

  Carries the structured details of a failed Telegram API request.
  """
  @type t :: %__MODULE__{
          type: atom(),
          code: integer() | nil,
          reason: atom() | nil,
          description: String.t() | nil,
          retry_after: integer() | nil,
          raw: map() | nil
        }

  defstruct type: :telegram,
            code: nil,
            reason: nil,
            description: nil,
            retry_after: nil,
            raw: nil

  @doc """
  Builds an `Error` struct from a raw Telegram API response body.

  ## Parameters

  - `body` - Raw response body map from Telegram API

  ## Returns

  A `TelegramEx.Error` struct.

  ## Examples

      iex> TelegramEx.Error.from_body(%{"error_code" => 429, "description" => "Too Many Requests", "parameters" => %{"retry_after" => 5}})
      %TelegramEx.Error{type: :telegram, code: 429, description: "Too Many Requests", retry_after: 5, raw: %{"error_code" => 429, "description" => "Too Many Requests", "parameters" => %{"retry_after" => 5}}}
  """
  @spec from_body(map()) :: t()
  def from_body(body) when is_map(body) do
    %__MODULE__{
      type: :telegram,
      code: body["error_code"],
      description: body["description"],
      retry_after: get_in(body, ["parameters", "retry_after"]),
      raw: body
    }
  end
end
