defmodule TelegramEx.MimeTypeTest do
  use ExUnit.Case

  doctest TelegramEx.MimeType

  alias TelegramEx.MimeType

  test "resolves image extensions to their MIME types" do
    assert MimeType.from_path("avatar.png") == "image/png"
    assert MimeType.from_path("animation.gif") == "image/gif"
    assert MimeType.from_path("sticker.webp") == "image/webp"
    assert MimeType.from_path("photo.jpg") == "image/jpeg"
  end

  test "resolves video extensions to their MIME types" do
    assert MimeType.from_path("clip.webm") == "video/webm"
    assert MimeType.from_path("movie.mp4") == "video/mp4"
  end

  test "lookup is case insensitive" do
    assert MimeType.from_path("PHOTO.PNG") == "image/png"
    assert MimeType.from_path("Clip.WebM") == "video/webm"
  end

  test "falls back to application/octet-stream for unknown extensions" do
    assert MimeType.from_path("archive.unknown") == "application/octet-stream"
    assert MimeType.from_path("noextension") == "application/octet-stream"
    assert MimeType.from_path("report.pdf") == "application/pdf"
  end

  test "default/0 returns the safe fallback type" do
    assert MimeType.default() == "application/octet-stream"
  end
end
