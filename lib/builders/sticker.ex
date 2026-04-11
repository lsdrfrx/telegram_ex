defmodule TelegramEx.Builder.Sticker do
  @moduledoc """
  Builder for sticker payloads.

      Sticker.path("/tmp/sticker.webp")
      |> Sticker.send(chat_id)

      Sticker.url("https://example.com/sticker.webp")
      |> Sticker.send(chat_id)

      Sticker.id("example_file_id")
      |> Sticker.send(chat_id)
  """

  alias TelegramEx.API

  def id(id) do
    %{sticker: id}
  end

  def url(url) do
    %{sticker: url}
  end

  def path(path) do
    filename = Path.basename(path)
    content = File.read!(path)

    %{
      sticker: {content, filename: filename, content_type: "image/webp"}
    }
  end

  def silent(sticker) do
    Map.put(sticker, :disable_notification, true)
  end

  def send(sticker, id) do
    sticker
    |> Map.put(:chat_id, id)
    |> then(&API.send_sticker(Process.get(:token), &1))
  end
end
