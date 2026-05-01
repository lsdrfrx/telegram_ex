defmodule TelegramEx.Builder.Video do
  @moduledoc """
  Builder for video payloads.

  This module provides a fluent API for sending videos from URLs, file paths,
  or Telegram file IDs. Videos can include duration, cover images, and other options.

  ## Examples

      # Send video from local file
      ctx
      |> Video.path("/tmp/video.mp4")
      |> Video.duration(120)
      |> Video.send(chat_id)

      # Send video from URL with cover
      ctx
      |> Video.url("https://example.com/video.mp4")
      |> Video.cover_url("https://example.com/cover.jpg")
      |> Video.send(chat_id)

      # Send video by file ID
      ctx
      |> Video.id("example_file_id")
      |> Video.send(chat_id)
  """

  alias TelegramEx.API

  @doc """
  Sets the video by Telegram file ID.

  ## Parameters

  - `ctx` - Context map
  - `id` - Telegram file ID

  ## Returns

  Updated context map with video ID set.
  """
  @spec id(map(), String.t()) :: map()
  def id(ctx, id) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:video, id)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sets the video from a URL.

  ## Parameters

  - `ctx` - Context map
  - `url` - URL of the video

  ## Returns

  Updated context map with video URL set.
  """
  @spec url(map(), String.t()) :: map()
  def url(ctx, url) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:video, url)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sets the video from a local file path.

  ## Parameters

  - `ctx` - Context map
  - `path` - Path to the video file

  ## Returns

  Updated context map with video file content set.
  """
  @spec path(map(), String.t()) :: map()
  def path(ctx, path) do
    filename = Path.basename(path)
    content = File.read!(path)

    Map.get(ctx, :payload, %{})
    |> Map.put(:video, {content, filename: filename, content_type: "video/mp4"})
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sets the video duration in seconds.

  ## Parameters

  - `ctx` - Context map
  - `seconds` - Duration in seconds

  ## Returns

  Updated context map with duration set.
  """
  @spec duration(map(), integer()) :: map()
  def duration(ctx, seconds) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:duration, seconds)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sets the video cover image from a local file path.

  ## Parameters

  - `ctx` - Context map
  - `path` - Path to the cover image file

  ## Returns

  Updated context map with cover image content set.
  """
  @spec cover_path(map(), String.t()) :: map()
  def cover_path(ctx, path) do
    filename = Path.basename(path)
    content = File.read!(path)

    Map.get(ctx, :payload, %{})
    |> Map.put(:cover, {content, filename: filename, content_type: "image/jpeg"})
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sets the video cover image from a URL.

  ## Parameters

  - `ctx` - Context map
  - `url` - URL of the cover image

  ## Returns

  Updated context map with cover image URL set.
  """
  @spec cover_url(map(), String.t()) :: map()
  def cover_url(ctx, url) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:cover, url)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sends the video without notification sound.

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
  Sends the video to the specified chat.

  ## Parameters

  - `ctx` - Context map with accumulated video data
  - `id` - Chat ID to send the video to

  ## Returns

  - `:ok` - Video sent successfully
  - `{:error, reason}` - Failed to send video
  """
  @spec send(map(), integer()) :: :ok | {:error, term()}
  def send(ctx, id) do
    ctx
    |> Map.put(:chat_id, id)
    |> Map.put(:method, "sendVideo")
    |> Map.put(:format, :multipart)
    |> API.request()
  end
end
