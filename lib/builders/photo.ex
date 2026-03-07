defmodule TelegramEx.Builder.Photo do
  alias TelegramEx.{Config, API}

  def new(id) do
    %{chat_id: id}
  end

  def url(photo, url) do
    Map.put(photo, :photo, url)
  end

  def path(photo, path) do
    File.stream!(path)
    |> then(fn stream ->
      Map.put(photo, :photo, stream)
    end)
  end

  def caption(photo, caption) do
    Map.put(photo, :caption, caption)
  end

  def caption(photo, caption, parse_mode) do
    photo
    |> Map.put(:caption, caption)
    |> Map.put(:parse_mode, parse_mode)
  end

  def send(photo) do
    API.send_photo(Config.token(), photo)
  end
end
