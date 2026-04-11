defmodule TelegramEx.Builder.Document do
  @moduledoc """
  Builder for document payloads.

      Document.path("/tmp/report.pdf")
      |> Document.caption("Report")
      |> Document.send(chat_id)
  """

  alias TelegramEx.API

  def url(url) do
    %{document: url}
  end

  def path(path) do
    filename = Path.basename(path)
    content = File.read!(path)

    %{
      document: {content, filename: filename, content_type: "application/octet-stream"}
    }
  end

  def caption(document, caption) do
    Map.put(document, :caption, caption)
  end

  def caption(document, caption, parse_mode) do
    document
    |> Map.put(:caption, caption)
    |> Map.put(:parse_mode, parse_mode)
  end

  def silent(document) do
    Map.put(document, :disable_notification, true)
  end

  def send(document, id) do
    document
    |> Map.put(:chat_id, id)
    |> then(&API.request(Process.get(:token), "sendDocument", &1, format: :multipart))
  end
end
