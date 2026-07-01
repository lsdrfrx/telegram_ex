defmodule TelegramEx.Builder.Document do
  @moduledoc """
  Builder for document payloads.

  Supports URLs, local file paths, captions, parse modes, and silent sends. See
  [Messages and Media](messages-and-media.md).
  """

  alias TelegramEx.API
  alias TelegramEx.Builder
  alias TelegramEx.Effect

  @type input :: map() | Effect.t()

  @doc """
  Sets the document from a URL.

  Accepts a handler context or an existing `TelegramEx.Effect` and returns an
  effect with `:document` stored in the payload.

  ## Parameters

  - `input` - Context map or effect
  - `url` - URL of the document

  ## Returns

  `TelegramEx.Effect` with the updated context.
  """
  @spec url(input(), String.t()) :: Effect.t()
  def url(input, url) do
    Builder.put_payload(input, :document, url)
  end

  @doc """
  Sets the document from a local file path.

  If the file cannot be read, the returned effect contains
  `{:file, reason}` as its error.

  ## Parameters

  - `input` - Context map or effect
  - `path` - Path to the document file

  ## Returns

  `TelegramEx.Effect` with the updated context or file-read error.
  """
  @spec path(input(), String.t()) :: Effect.t()
  def path(input, path) do
    Builder.put_file_payload(input, :document, path)
  end

  @doc """
  Sets the document caption.

  Accepts a handler context or an existing `TelegramEx.Effect` and returns an
  effect with `:caption` stored in the payload.

  ## Parameters

  - `input` - Context map or effect
  - `caption` - Caption text

  ## Returns

  `TelegramEx.Effect` with the updated context.
  """
  @spec caption(input(), String.t()) :: Effect.t()
  def caption(input, caption) do
    Builder.put_payload(input, :caption, caption)
  end

  @doc """
  Sets the document caption with parse mode.

  Accepts a handler context or an existing `TelegramEx.Effect` and returns an
  effect with `:caption` and `:parse_mode` stored in the payload.

  ## Parameters

  - `input` - Context map or effect
  - `caption` - Caption text
  - `parse_mode` - Parse mode ("Markdown", "MarkdownV2", or "HTML")

  ## Returns

  `TelegramEx.Effect` with the updated context.
  """
  @spec caption(input(), String.t(), String.t()) :: Effect.t()
  def caption(input, caption, parse_mode) do
    input
    |> Builder.put_payload(:caption, caption)
    |> Builder.put_payload(:parse_mode, parse_mode)
  end

  @doc """
  Sends the document without notification sound.

  Accepts a handler context or an existing `TelegramEx.Effect` and returns an
  effect with `:disable_notification` stored in the payload.

  ## Parameters

  - `input` - Context map or effect

  ## Returns

  `TelegramEx.Effect` with the updated context.
  """
  @spec silent(input()) :: Effect.t()
  def silent(input) do
    Builder.put_payload(input, :disable_notification, true)
  end

  @doc """
  Sends the document to the specified chat.

  The returned effect contains an API error if the request fails.

  ## Parameters

  - `input` - Context map or effect with accumulated document data
  - `id` - Chat ID to send the document to

  ## Returns

  `TelegramEx.Effect` with the request result encoded in the effect state.
  """
  @spec send(input(), integer()) :: Effect.t()
  def send(input, id) do
    input
    |> Effect.wrap()
    |> Effect.then(fn ctx ->
      new_ctx =
        ctx
        |> Map.put(:chat_id, id)
        |> Map.put(:method, "sendDocument")
        |> Map.put(:format, :multipart)

      case API.request(new_ctx) do
        :ok -> {:ok, new_ctx}
        {:error, reason} -> {:error, reason}
      end
    end)
  end
end
