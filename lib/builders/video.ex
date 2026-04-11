defmodule TelegramEx.Builder.Video do
  @moduledoc """
  Builder for video payloads.

      Video.path("/tmp/video.mp4")
      |> Video.send(chat_id)

      Video.url("https://example.com/video.mp4")
      |> Video.send(chat_id)

      Video.id("example_file_id")
      |> Video.send(chat_id)
  """

  alias TelegramEx.API

  def id(id) do
    %{video: id}
  end

  def url(url) do
    %{video: url}
  end

  def path(path) do
    filename = Path.basename(path)
    content = File.read!(path)

    %{
      video: {content, filename: filename, content_type: "video/mp4"}
    }
  end

  def duration(video, seconds) do
    Map.put(video, :duration, seconds)
  end

  def cover_path(video, path) do
    filename = Path.basename(path)
    content = File.read!(path)

    Map.put(video, :cover, {content, filename: filename, content_type: "image/jpeg"})
  end

  def cover_url(video, url) do
    Map.put(video, :cover, url)
  end

  def silent(video) do
    Map.put(video, :disable_notification, true)
  end

  def send(video, id) do
    video
    |> Map.put(:chat_id, id)
    |> then(&API.request(Process.get(:token), "sendVideo", &1, format: :multipart))
  end
end
