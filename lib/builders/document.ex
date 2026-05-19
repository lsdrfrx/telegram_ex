defmodule TelegramEx.Builder.Document do
  @moduledoc """
  Builder for document payloads.

  This module provides a fluent API for sending documents (files) from URLs,
  file paths, or Telegram file IDs. Documents can include captions and parse modes.

  ## Examples

      # Send document from URL
      ctx
      |> Document.url("https://example.com/report.pdf")
      |> Document.caption("Monthly Report")
      |> Document.send(chat_id)

      # Send document from local file
      ctx
      |> Document.path("/path/to/file.pdf")
      |> Document.caption("Important document", "Markdown")
      |> Document.send(chat_id)

      # Send document silently
      ctx
      |> Document.path("/path/to/file.pdf")
      |> Document.silent()
      |> Document.send(chat_id)
  """

  alias TelegramEx.API
  alias TelegramEx.MimeType

  @doc """
  Sets the document from a URL.

  ## Parameters

  - `ctx` - Context map
  - `url` - URL of the document

  ## Returns

  Updated context map with document URL set.
  """
  @spec url(map(), String.t()) :: map()
  def url(ctx, url) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:document, url)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sets the document from a local file path.

  ## Parameters

  - `ctx` - Context map
  - `path` - Path to the document file

  ## Returns

  - `{:ok, updated_ctx}` - Document loaded successfully
  - `{:error, reason}` - Failed to read file

  ## Examples

      case Document.path(ctx, "/path/to/file.pdf") do
        {:ok, ctx} -> ctx |> Document.send(chat_id)
        {:error, :enoent} -> Message.text(ctx, "File not found") |> Message.send(chat_id)
        {:error, _} -> Message.text(ctx, "Failed to load document") |> Message.send(chat_id)
      end
  """
  @spec path(map(), String.t()) :: {:ok, map()} | {:error, atom()}
  def path(ctx, path) do
    case(File.read(path)) do
      {:ok, content} ->
        filename = Path.basename(path)

        updated_payload =
          Map.get(ctx, :payload, %{})
          |> Map.put(
            :document,
            {content, filename: filename, content_type: MimeType.from_path(path)}
          )

        {:ok, Map.put(ctx, :payload, updated_payload)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Sets the document caption.

  ## Parameters

  - `ctx` - Context map
  - `caption` - Caption text

  ## Returns

  Updated context map with caption set.
  """
  @spec caption(map(), String.t()) :: map()
  def caption(ctx, caption) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:caption, caption)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sets the document caption with parse mode.

  ## Parameters

  - `ctx` - Context map
  - `caption` - Caption text
  - `parse_mode` - Parse mode ("Markdown", "MarkdownV2", or "HTML")

  ## Returns

  Updated context map with caption and parse mode set.
  """
  @spec caption(map(), String.t(), String.t()) :: map()
  def caption(ctx, caption, parse_mode) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:caption, caption)
    |> Map.put(:parse_mode, parse_mode)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sends the document without notification sound.

  ## Parameters

  - `ctx` - Context map

  ## Returns

  Updated context map with silent flag set.
  """
  @spec silent(map()) :: map()
  def silent(ctx) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:disable_notification, true)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sends the document to the specified chat.

  ## Parameters

  - `ctx` - Context map with accumulated document data
  - `id` - Chat ID to send the document to

  ## Returns

  - `:ok` - Document sent successfully
  - `{:error, reason}` - Failed to send document
  """
  @spec send(map(), integer()) :: :ok | {:error, term()}
  def send(ctx, id) do
    ctx
    |> Map.put(:chat_id, id)
    |> Map.put(:method, "sendDocument")
    |> Map.put(:format, :multipart)
    |> API.request()
  end
end
