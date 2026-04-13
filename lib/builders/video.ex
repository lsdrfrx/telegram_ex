defmodule TelegramEx.Builder.Video do
  @moduledoc """
  Builder for video payloads.

      Video.path(ctx, "/tmp/video.mp4")
      |> Video.send(chat_id)

      Video.url(ctx, "https://example.com/video.mp4")
      |> Video.send(chat_id)

      Video.id(ctx, "example_file_id")
      |> Video.send(chat_id)
  """

  alias TelegramEx.API

  def id(ctx, id) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:video, id)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def url(ctx, url) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:video, url)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def path(ctx, path) do
    filename = Path.basename(path)
    content = File.read!(path)

    Map.get(ctx, :payload, %{})
    |> Map.put(:video, {content, filename: filename, content_type: "video/mp4"})
    |> then(&Map.put(ctx, :payload, &1))
  end

  def duration(ctx, seconds) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:duration, seconds)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def cover_path(ctx, path) do
    filename = Path.basename(path)
    content = File.read!(path)

    Map.get(ctx, :payload, %{})
    |> Map.put(:cover, {content, filename: filename, content_type: "image/jpeg"})
    |> then(&Map.put(ctx, :payload, &1))
  end

  def cover_url(ctx, url) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:cover, url)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def silent(ctx) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:disable_notification, true)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def send(ctx, id) do
    ctx
    |> Map.put(:chat_id, id)
    |> Map.put(:method, "sendVideo")
    |> Map.put(:format, :multipart)
    |> API.request()
  end
end
