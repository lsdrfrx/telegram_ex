defmodule Example.Routers.Commands do
  @moduledoc """
  Demonstrates command handlers defined with `TelegramEx.Command.defcommand/3`.
  """
  use TelegramEx.Router

  defcommand "command_demo", description: "Show defcommand example", bind: [:ctx, :message] do
    ctx
    |> Message.text(
      "This response is handled by `defcommand` in `Example.Routers.Commands`.",
      "Markdown"
    )
    |> Message.send(message.chat["id"])
  end

  defcommand "echo", description: "Echo command arguments", bind: [:ctx, :message, :args] do
    text =
      case args do
        [] -> "Usage: /echo hello world"
        args -> Enum.join(args, " ")
      end

    ctx
    |> Message.text(text)
    |> Message.send(message.chat["id"])
  end
end
