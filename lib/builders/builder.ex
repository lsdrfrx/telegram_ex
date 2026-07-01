defmodule TelegramEx.Builder do
  @moduledoc """
  Shared helpers for TelegramEx builder modules.
  """

  alias TelegramEx.Effect
  alias TelegramEx.MimeType

  @type input :: map() | Effect.t()

  @doc """
  Adds a value to the effect payload.
  """
  @spec put_payload(input(), atom(), term()) :: Effect.t()
  def put_payload(input, key, value) do
    input
    |> Effect.wrap()
    |> Effect.map_ctx(fn ctx ->
      Map.get(ctx, :payload, %{})
      |> Map.put(key, value)
      |> then(&Map.put(ctx, :payload, &1))
    end)
  end

  @doc """
  Reads a local file and adds it as a multipart payload value.

  If the file cannot be read, the returned effect contains `{:file, reason}`.
  """
  @spec put_file_payload(input(), atom(), String.t()) :: Effect.t()
  def put_file_payload(input, key, path) do
    input
    |> Effect.wrap()
    |> Effect.then(fn ctx ->
      case File.read(path) do
        {:ok, content} ->
          {:ok, put_raw_file_payload(ctx, key, path, content)}

        {:error, reason} ->
          {:error, {:file, reason}}
      end
    end)
  end

  defp put_raw_file_payload(ctx, key, path, content) do
    filename = Path.basename(path)
    file = {content, filename: filename, content_type: MimeType.from_path(path)}

    ctx
    |> Map.get(:payload, %{})
    |> Map.put(key, file)
    |> then(&Map.put(ctx, :payload, &1))
  end
end
