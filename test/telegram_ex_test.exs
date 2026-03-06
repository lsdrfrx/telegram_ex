defmodule TelegramExTest do
  use ExUnit.Case
  doctest TelegramEx

  test "greets the world" do
    assert TelegramEx.hello() == :world
  end
end
