defmodule TelegramEx.Builder.Photo do
  alias TelegramEx.{Config, API}

  def url(url) do
    %{photo: url}
  end

  def path(path) do
    File.stream!(path)
    |> then(fn stream ->
      %{photo: stream}
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

  def send(photo, id) do
    photo
    |> Map.put(:chat_id, id)
    |> then(fn photo ->
      API.send_photo(Config.token(), photo)
    end)
  end
end
