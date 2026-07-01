defmodule TelegramEx.Builder.Photo do
  @moduledoc """
  Builder for photo payloads.

  Supports URLs, local file paths, captions, parse modes, and silent sends. See
  [Messages and Media](messages-and-media.md).
  """

  alias TelegramEx.API
  alias TelegramEx.Builder
  alias TelegramEx.Effect
  alias TelegramEx.MimeType

  @type input :: map() | Effect.t()

  @doc """
  Sets the photo from a URL.
  """
  @spec url(input(), String.t()) :: Effect.t()
  def url(input, url) do
    Builder.put_payload(input, :photo, url)
  end

  @doc """
  Sets the photo from a local file path.

  If the file cannot be read, the returned effect contains `{:file, reason}`.
  """
  @spec path(input(), String.t()) :: Effect.t()
  def path(input, path) do
    input
    |> Effect.wrap()
    |> Effect.then(fn ctx ->
      filename = Path.basename(path)

      with {:ok, content} <- File.read(path) do
        payload =
          ctx
          |> Map.get(:payload, %{})
          |> Map.put(
            :photo,
            {content, filename: filename, content_type: MimeType.from_path(path)}
          )

        {:ok, Map.put(ctx, :payload, payload)}
      else
        {:error, reason} -> {:error, {:file, reason}}
      end
    end)
  end

  @doc """
  Sets the photo caption.
  """
  @spec caption(input(), String.t()) :: Effect.t()
  def caption(input, caption) do
    Builder.put_payload(input, :caption, caption)
  end

  @doc """
  Sets the photo caption with parse mode.
  """
  @spec caption(input(), String.t(), String.t()) :: Effect.t()
  def caption(input, caption, parse_mode) do
    input
    |> Builder.put_payload(:caption, caption)
    |> Builder.put_payload(:parse_mode, parse_mode)
  end

  @doc """
  Sends the photo without notification sound.
  """
  @spec silent(input()) :: Effect.t()
  def silent(input) do
    Builder.put_payload(input, :disable_notification, true)
  end

  @doc """
  Sends the photo to the specified chat.
  """
  @spec send(input(), integer()) :: Effect.t()
  def send(input, id) do
    input
    |> Effect.wrap()
    |> Effect.then(fn ctx ->
      new_ctx =
        ctx
        |> Map.put(:chat_id, id)
        |> Map.put(:method, "sendPhoto")
        |> Map.put(:format, :multipart)

      case API.request(new_ctx) do
        :ok -> {:ok, new_ctx}
        {:error, reason} -> {:error, reason}
      end
    end)
  end
end
