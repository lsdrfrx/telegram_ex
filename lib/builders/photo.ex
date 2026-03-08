defmodule TelegramEx.Builder.Photo do
  alias TelegramEx.{Config, API}

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

  def silent(message) do
    Map.put(message, :disable_notification, true)
  end

  def send(photo, id) do
    photo
    |> Map.put(:chat_id, id)
    |> then(&API.send_photo(Config.token(), &1))
  end
end
