defmodule TelegramEx.Builder.Photo do
  @moduledoc """
  Builder for photo payloads.

  This module provides a fluent API for sending photos from URLs, file paths,
  or Telegram file IDs. Photos can include captions, parse modes, and other options.

  ## Examples

      # Send photo from URL
      ctx
      |> Photo.url("https://example.com/image.jpg")
      |> Photo.caption("Look at this")
      |> Photo.send(chat_id)

      # Send photo from local file
      ctx
      |> Photo.path("/path/to/image.jpg")
      |> Photo.caption("Local photo", "Markdown")
      |> Photo.send(chat_id)

      # Send photo silently
      ctx
      |> Photo.url("https://example.com/image.jpg")
      |> Photo.silent()
      |> Photo.send(chat_id)
  """

  alias TelegramEx.API

  @doc """
  Sets the photo from a URL.

  ## Parameters

  - `ctx` - Context map
  - `url` - URL of the photo

  ## Returns

  Updated context map with photo URL set.

  ## Examples

      ctx
      |> Photo.url("https://example.com/photo.jpg")
      |> Photo.send(chat_id)
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

  ## Examples

      ctx
      |> Photo.path("/tmp/photo.jpg")
      |> Photo.send(chat_id)
  """
  @spec path(map(), String.t()) :: map()
  def path(ctx, path) do
    filename = Path.basename(path)
    content = File.read!(path)

    Map.get(ctx, :payload, %{})
    |> Map.put(:photo, {content, filename: filename, content_type: "image/jpeg"})
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sets the photo caption.

  ## Parameters

  - `ctx` - Context map
  - `caption` - Caption text

  ## Returns

  Updated context map with caption set.

  ## Examples

      ctx
      |> Photo.url("https://example.com/photo.jpg")
      |> Photo.caption("Beautiful sunset")
      |> Photo.send(chat_id)
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

  ## Examples

      ctx
      |> Photo.url("https://example.com/photo.jpg")
      |> Photo.caption("*Bold* caption", "Markdown")
      |> Photo.send(chat_id)
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

  ## Examples

      ctx
      |> Photo.url("https://example.com/photo.jpg")
      |> Photo.silent()
      |> Photo.send(chat_id)
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

  ## Examples

      ctx
      |> Photo.url("https://example.com/photo.jpg")
      |> Photo.send(chat_id)
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
