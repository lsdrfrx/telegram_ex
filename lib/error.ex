defmodule TelegramEx.Error do
  @moduledoc """
  Struct representing an error returned by the Telegram Bot API.

  Captures Telegram error responses in a structured form.

  ## Fields

  - `:type` - Source of the error (`:telegram` for API errors)
  - `:code` - Numeric error code from `error_code` (nil if absent)
  - `:reason` - Optional atom describing the error (nil unless provided)
  - `:description` - Human-readable description from the API
  - `:retry_after` - Seconds to wait before retrying, from `parameters.retry_after` (nil if absent)
  - `:raw` - The raw response body, for callers that need the full payload

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
