defmodule TelegramEx.Builder.Video do
  @moduledoc """
  Builder for video payloads.

  Supports file IDs, URLs, local files, duration, cover images, and silent
  sends. See [Messages and Media](messages-and-media.md).
  """

  alias TelegramEx.API
  alias TelegramEx.Builder
  alias TelegramEx.Effect

  @type input :: map() | Effect.t()

  @doc """
  Sets the video by Telegram file ID.
  """
  @spec id(input(), String.t()) :: Effect.t()
  def id(input, id) do
    Builder.put_payload(input, :video, id)
  end

  @doc """
  Sets the video from a URL.
  """
  @spec url(input(), String.t()) :: Effect.t()
  def url(input, url) do
    Builder.put_payload(input, :video, url)
  end

  @doc """
  Sets the video from a local file path.

  If the file cannot be read, the returned effect contains `{:file, reason}`.
  """
  @spec path(input(), String.t()) :: Effect.t()
  def path(input, path) do
    put_file_payload(input, :video, path)
  end

  @doc """
  Sets the video duration in seconds.
  """
  @spec duration(input(), integer()) :: Effect.t()
  def duration(input, seconds) do
    Builder.put_payload(input, :duration, seconds)
  end

  @doc """
  Sets the video cover image from a local file path.

  If the file cannot be read, the returned effect contains `{:file, reason}`.
  """
  @spec cover_path(input(), String.t()) :: Effect.t()
  def cover_path(input, path) do
    put_file_payload(input, :cover, path)
  end

  @doc """
  Sets the video cover image from a URL.
  """
  @spec cover_url(input(), String.t()) :: Effect.t()
  def cover_url(input, url) do
    Builder.put_payload(input, :cover, url)
  end

  @doc """
  Sends the video without notification sound.
  """
  @spec silent(input()) :: Effect.t()
  def silent(input) do
    Builder.put_payload(input, :disable_notification, true)
  end

  @doc """
  Sends the video to the specified chat.
  """
  @spec send(input(), integer()) :: Effect.t()
  def send(input, id) do
    input
    |> Effect.wrap()
    |> Effect.then(fn ctx ->
      new_ctx =
        ctx
        |> Map.put(:chat_id, id)
        |> Map.put(:method, "sendVideo")
        |> Map.put(:format, :multipart)

      case API.request(new_ctx) do
        :ok -> {:ok, new_ctx}
        {:error, reason} -> {:error, reason}
      end
    end)
  end

  defp put_file_payload(input, key, path) do
    Builder.put_file_payload(input, key, path)
  end
end
