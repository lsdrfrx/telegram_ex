defmodule TelegramEx.Builder.Photo do
  @moduledoc """
  Builder for photo payloads.

      Photo.path("/tmp/img.jpg")
      |> Photo.caption("Look at this")
      |> Photo.send(chat_id)
  """

  alias TelegramEx.API

  def url(url) do
    %{photo: url}
  end

  def path(path) do
    filename = Path.basename(path)
    content = File.read!(path)

    %{
      photo: {content, filename: filename, content_type: "image/jpeg"}
    }
  end

  def caption(photo, caption) do
    Map.put(photo, :caption, caption)
  end

  def caption(photo, caption, parse_mode) do
    photo
    |> Map.put(:caption, caption)
    |> Map.put(:parse_mode, parse_mode)
  end

  def silent(photo) do
    Map.put(photo, :disable_notification, true)
  end

  def send(photo, id) do
    photo
    |> Map.put(:chat_id, id)
    |> then(&API.send_photo(Process.get(:token), &1))
  end
end
