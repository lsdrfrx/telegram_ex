defmodule TelegramEx.Builder.Sticker do
  @moduledoc """
  Builder for sticker payloads.

  This module provides a fluent API for sending stickers from Telegram file IDs,
  URLs, or local file paths.

  ## Examples

      # Send sticker by file ID
      ctx
      |> Sticker.id("CAACAgIAAxkBA...")
      |> Sticker.send(chat_id)

      # Send sticker from URL
      ctx
      |> Sticker.url("https://example.com/sticker.webp")
      |> Sticker.send(chat_id)

      # Send sticker from local file
      ctx
      |> Sticker.path("/tmp/sticker.webp")
      |> Sticker.send(chat_id)
  """

  alias TelegramEx.API
  alias TelegramEx.MimeType

  @doc """
  Sets the sticker by Telegram file ID.

  ## Parameters

  - `ctx` - Context map
  - `id` - Telegram file ID of the sticker

  ## Returns

  Updated context map with sticker ID set.
  """
  @spec id(map(), String.t()) :: map()
  def id(ctx, id) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:sticker, id)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sets the sticker from a URL.

  ## Parameters

  - `ctx` - Context map
  - `url` - URL of the sticker

  ## Returns

  Updated context map with sticker URL set.
  """
  @spec url(map(), String.t()) :: map()
  def url(ctx, url) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:sticker, url)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sets the sticker from a local file path.

  ## Parameters

  - `ctx` - Context map
  - `path` - Path to the sticker file

  ## Returns

  - `{:ok, updated_ctx}` - Sticker loaded successfully
  - `{:error, reason}` - Failed to read file

  ## Examples

      case Sticker.path(ctx, "/tmp/sticker.webp") do
        {:ok, ctx} -> ctx |> Sticker.send(chat_id)
        {:error, _} -> Message.text(ctx, "Failed to load sticker") |> Message.send(chat_id)
      end
  """
  @spec path(map(), String.t()) :: {:ok, map()} | {:error, atom()}
  def path(ctx, path) do
    case File.read(path) do
      {:ok, content} ->
        filename = Path.basename(path)

        updated_payload =
          Map.get(ctx, :payload, %{})
          |> Map.put(
            :sticker,
            {content, filename: filename, content_type: MimeType.from_path(path)}
          )

        {:ok, Map.put(ctx, :payload, updated_payload)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Sends the sticker without notification sound.

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
  Sends the sticker to the specified chat.

  ## Parameters

  - `ctx` - Context map with accumulated sticker data
  - `id` - Chat ID to send the sticker to

  ## Returns

  - `:ok` - Sticker sent successfully
  - `{:error, reason}` - Failed to send sticker
  """
  @spec send(map(), integer()) :: :ok | {:error, term()}
  def send(ctx, id) do
    ctx
    |> Map.put(:chat_id, id)
    |> Map.put(:method, "sendSticker")
    |> Map.put(:format, :multipart)
    |> API.request()
  end
end
