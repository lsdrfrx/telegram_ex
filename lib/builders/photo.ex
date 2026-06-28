defmodule TelegramEx.Builder.Photo do
  @moduledoc """
  Builder for photo payloads.

  Supports URLs, local file paths, captions, parse modes, and silent sends. See
  [Messages and Media](messages-and-media.md).
  """

  alias TelegramEx.API
  alias TelegramEx.MimeType

  @doc """
  Sets the photo from a URL.

  ## Parameters

  - `ctx` - Context map
  - `url` - URL of the photo

  ## Returns

  Updated context map with photo URL set.

  """
  @spec url(map(), String.t()) :: map()
  def url(ctx, url) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:photo, url)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sets the photo from a local file path.

  ## Parameters

  - `ctx` - Context map
  - `path` - Path to the photo file

  ## Returns

  Updated context map with photo file content set.

  """
  @spec path(map(), String.t()) :: map()
  def path(ctx, path) do
    filename = Path.basename(path)
    content = File.read!(path)

    Map.get(ctx, :payload, %{})
    |> Map.put(:photo, {content, filename: filename, content_type: MimeType.from_path(path)})
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sets the photo caption.

  ## Parameters

  - `ctx` - Context map
  - `caption` - Caption text

  ## Returns

  Updated context map with caption set.

  """
  @spec caption(map(), String.t()) :: map()
  def caption(ctx, caption) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:caption, caption)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sets the photo caption with parse mode.

  ## Parameters

  - `ctx` - Context map
  - `caption` - Caption text
  - `parse_mode` - Parse mode ("Markdown", "MarkdownV2", or "HTML")

  ## Returns

  Updated context map with caption and parse mode set.

  """
  @spec caption(map(), String.t(), String.t()) :: map()
  def caption(ctx, caption, parse_mode) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:caption, caption)
    |> Map.put(:parse_mode, parse_mode)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sends the photo without notification sound.

  ## Parameters

  - `ctx` - Context map

  ## Returns

  Updated context map with silent flag set.

  """
  @spec silent(map()) :: map()
  def silent(ctx) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:disable_notification, true)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sends the photo to the specified chat.

  ## Parameters

  - `ctx` - Context map with accumulated photo data
  - `id` - Chat ID to send the photo to

  ## Returns

  - `:ok` - Photo sent successfully
  - `{:error, reason}` - Failed to send photo

  """
  @spec send(map(), integer()) :: :ok | {:error, term()}
  def send(ctx, id) do
    ctx
    |> Map.put(:chat_id, id)
    |> Map.put(:method, "sendPhoto")
    |> Map.put(:format, :multipart)
    |> API.request()
  end
end
