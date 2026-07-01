defmodule TelegramEx.Builder.Sticker do
  @moduledoc """
  Builder for sticker payloads.

  Supports Telegram file IDs, URLs, local files, and silent sends. See
  [Messages and Media](messages-and-media.md).
  """

  alias TelegramEx.API
  alias TelegramEx.Builder
  alias TelegramEx.Effect
  alias TelegramEx.MimeType

  @type input :: map() | Effect.t()

  @doc """
  Sets the sticker by Telegram file ID.
  """
  @spec id(input(), String.t()) :: Effect.t()
  def id(input, id) do
    Builder.put_payload(input, :sticker, id)
  end

  @doc """
  Sets the sticker from a URL.
  """
  @spec url(input(), String.t()) :: Effect.t()
  def url(input, url) do
    Builder.put_payload(input, :sticker, url)
  end

  @doc """
  Sets the sticker from a local file path.

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
            :sticker,
            {content, filename: filename, content_type: MimeType.from_path(path)}
          )

        {:ok, Map.put(ctx, :payload, payload)}
      else
        {:error, reason} -> {:error, {:file, reason}}
      end
    end)
  end

  @doc """
  Sends the sticker without notification sound.
  """
  @spec silent(input()) :: Effect.t()
  def silent(input) do
    Builder.put_payload(input, :disable_notification, true)
  end

  @doc """
  Sends the sticker to the specified chat.
  """
  @spec send(input(), integer()) :: Effect.t()
  def send(input, id) do
    input
    |> Effect.wrap()
    |> Effect.then(fn ctx ->
      new_ctx =
        ctx
        |> Map.put(:chat_id, id)
        |> Map.put(:method, "sendSticker")
        |> Map.put(:format, :multipart)

      case API.request(new_ctx) do
        :ok -> {:ok, new_ctx}
        {:error, reason} -> {:error, reason}
      end
    end)
  end
end
