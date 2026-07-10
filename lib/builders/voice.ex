defmodule TelegramEx.Builder.Voice do
  @moduledoc """
  Builder for voice message payloads.

  Supports Telegram file IDs, URLs, local files, captions, parse modes,
  duration, and silent sends. See [Messages and Media](messages-and-media.md).
  """

  use TelegramEx.Builder

  @doc """
  Sets the voice message by Telegram file ID.
  """
  @spec id(input(), String.t()) :: Effect.t()
  def id(input, id) do
    Builder.put_payload(input, :voice, id)
  end

  @doc """
  Sets the voice message from a URL.
  """
  @spec url(input(), String.t()) :: Effect.t()
  def url(input, url) do
    Builder.put_payload(input, :voice, url)
  end

  @doc """
  Sets the voice message from a local file path.

  If the file cannot be read, the returned effect contains `{:file, reason}`.
  """
  @spec path(input(), String.t()) :: Effect.t()
  def path(input, path) do
    Builder.put_file_payload(input, :voice, path)
  end

  @doc """
  Sets the voice message caption.
  """
  @spec caption(input(), String.t()) :: Effect.t()
  def caption(input, caption) do
    Builder.put_payload(input, :caption, caption)
  end

  @doc """
  Sets the voice message caption with parse mode.
  """
  @spec caption(input(), String.t(), String.t()) :: Effect.t()
  def caption(input, caption, parse_mode) do
    input
    |> Builder.put_payload(:caption, caption)
    |> Builder.put_payload(:parse_mode, parse_mode)
  end

  @doc """
  Sets the voice message duration in seconds.
  """
  @spec duration(input(), integer()) :: Effect.t()
  def duration(input, seconds) do
    Builder.put_payload(input, :duration, seconds)
  end

  @doc """
  Sends the voice message to the specified chat.
  """
  @spec send(input(), integer()) :: Effect.t()
  def send(input, id) do
    input
    |> Effect.wrap()
    |> Effect.then(fn ctx ->
      new_ctx =
        ctx
        |> Map.put(:chat_id, id)
        |> Map.put(:method, "sendVoice")
        |> Map.put(:format, :multipart)

      case API.request(new_ctx) do
        :ok -> {:ok, new_ctx}
        {:error, reason} -> {:error, reason}
      end
    end)
  end
end
