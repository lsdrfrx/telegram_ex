defmodule Builder do
  use TelegramEx.Builder
end

defmodule TelegramEx.BuilderTest do
  use ExUnit.Case

  test "silent/1 adds disable_notification to payload" do
    effect = Builder.silent(%{})

    assert effect.ctx.payload == %{disable_notification: true}
  end

  test "reply_to/2 adds reply parameters to payload" do
    effect = Builder.reply_to(%{}, 123)

    assert effect.ctx.payload == %{reply_parameters: %{message_id: 123}}
  end
end
