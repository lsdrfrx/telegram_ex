defmodule TelegramEx.MimeType do
  @moduledoc """
  Resolves MIME content types for local files based on their extension.

  This is used by the file-based builders (`Photo`, `Video`, `Sticker`,
  `Document`) so that uploaded media carries the correct `Content-Type`
  header instead of a hardcoded value.
  """

  @types %{
    ".jpg" => "image/jpeg",
    ".jpeg" => "image/jpeg",
    ".png" => "image/png",
    ".gif" => "image/gif",
    ".webp" => "image/webp",
    ".bmp" => "image/bmp",
    ".tif" => "image/tiff",
    ".tiff" => "image/tiff",
    ".svg" => "image/svg+xml",
    ".mp4" => "video/mp4",
    ".webm" => "video/webm",
    ".mov" => "video/quicktime",
    ".avi" => "video/x-msvideo",
    ".mkv" => "video/x-matroska",
    ".mpeg" => "video/mpeg",
    ".mpg" => "video/mpeg",
    ".mp3" => "audio/mpeg",
    ".ogg" => "audio/ogg",
    ".wav" => "audio/wav",
    ".m4a" => "audio/mp4",
    ".pdf" => "application/pdf",
    ".zip" => "application/zip",
    ".json" => "application/json",
    ".txt" => "text/plain",
    ".csv" => "text/csv",
    ".html" => "text/html"
  }

  @default "application/octet-stream"

  @doc """
  Returns the MIME content type for the given file path.

  The lookup is based on the lowercased file extension. Unknown extensions
  fall back to `#{@default}`.

  ## Parameters

  - `path` - Path or filename of the file

  ## Returns

  A MIME content type string.

  ## Examples

      iex> TelegramEx.MimeType.from_path("photo.PNG")
      "image/png"

      iex> TelegramEx.MimeType.from_path("clip.webm")
      "video/webm"

      iex> TelegramEx.MimeType.from_path("archive.unknown")
      "application/octet-stream"
  """
  @spec from_path(String.t()) :: String.t()
  def from_path(path) do
    extension = path |> Path.extname() |> String.downcase()
    Map.get(@types, extension, @default)
  end

  @doc """
  Returns the fallback MIME content type used for unknown extensions.
  """
  @spec default() :: String.t()
  def default, do: @default
end
