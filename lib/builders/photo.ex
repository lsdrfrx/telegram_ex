defmodule TelegramEx.Builder.Photo do
  @moduledoc """
  Builder for photo payloads.

      Photo.url(ctx, "https://...")
      |> Photo.caption("Look at this")
      |> Photo.send(chat_id)
  """

  alias TelegramEx.API

  def url(ctx, url) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:photo, url)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def path(ctx, path) do
    filename = Path.basename(path)
    content = File.read!(path)

    Map.get(ctx, :payload, %{})
    |> Map.put(:photo, {content, filename: filename, content_type: "image/jpeg"})
    |> then(&Map.put(ctx, :payload, &1))
  end

  def caption(ctx, caption) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:caption, caption)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def caption(ctx, caption, parse_mode) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:caption, caption)
    |> Map.put(:parse_mode, parse_mode)
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
    |> Map.put(:method, "sendPhoto")
    |> Map.put(:format, :multipart)
    |> API.request()
  end
end
