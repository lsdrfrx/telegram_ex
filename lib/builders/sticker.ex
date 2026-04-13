defmodule TelegramEx.Builder.Sticker do
  @moduledoc """
  Builder for sticker payloads.

      Sticker.id(ctx, "example_file_id")
      |> Sticker.send(chat_id)

      Sticker.url(ctx, "https://example.com/sticker.webp")
      |> Sticker.send(chat_id)

      Sticker.path(ctx, "/tmp/sticker.webp")
      |> Sticker.send(chat_id)
  """

  alias TelegramEx.API

  def id(ctx, id) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:sticker, id)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def url(ctx, url) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:sticker, url)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def path(ctx, path) do
    filename = Path.basename(path)
    content = File.read!(path)

    Map.get(ctx, :payload, %{})
    |> Map.put(:sticker, {content, filename: filename, content_type: "image/webp"})
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
    |> Map.put(:method, "sendSticker")
    |> Map.put(:format, :multipart)
    |> API.request()
  end
end
