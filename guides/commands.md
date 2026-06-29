# Commands

Telegram commands are text messages that start with `/`, such as `/start` or
`/echo hello`. TelegramEx treats them as normal message handlers and adds a DSL
for registering command metadata with Telegram.

## Why `defcommand/3` Exists

Telegram has two separate concerns:

- dispatching `/start` when the user sends a message
- showing `/start` in the Telegram command menu

`defcommand/3` handles both:

```elixir
defcommand "start", description: "Show welcome message", bind: [:ctx, :message] do
  ctx
  |> Message.text("Welcome!")
  |> Message.send(message.chat["id"])
end
```

The command name is written without `/`. The description is required because
Telegram requires descriptions for `setMyCommands`.

## Macro Expansion

Conceptually, this:

```elixir
defcommand "start", description: "Show welcome message", bind: [:ctx, :message] do
  ctx
  |> Message.text("Welcome!")
  |> Message.send(message.chat["id"])
end
```

expands into something close to:

```elixir
@commands %{command: "start", description: "Show welcome message"}

def handle_message(%{text: "/start" <> _rest} = message, ctx) do
  var!(ctx) = ctx
  var!(message) = message

  ctx
  |> Message.text("Welcome!")
  |> Message.send(message.chat["id"])
end
```

If `:args` is bound, the generated function also parses arguments:

```elixir
args = String.split(message.text, " ") |> Enum.drop(1)
var!(args) = args
```

If `:command` is bound, the generated function builds a
`%TelegramEx.Command{}` struct with the command name, description, and original
message.

## Bindings

The command body only sees variables listed in `:bind`. This keeps macro hygiene
explicit and avoids accidental variables appearing in user code.

Available bindings:

- `:ctx` - handler context
- `:message` - original Telegram message
- `:args` - command arguments split by spaces
- `:command` - `%TelegramEx.Command{}` for the matched command

Example with arguments:

```elixir
defcommand "echo", description: "Echo text", bind: [:ctx, :message, :args] do
  text =
    case args do
      [] -> "Usage: /echo hello"
      args -> Enum.join(args, " ")
    end

  ctx
  |> Message.text(text)
  |> Message.send(message.chat["id"])
end
```

`/echo hello world` sends `hello world`. The argument parser is intentionally
simple: it splits on spaces. If your command needs quoted strings, flags, or
typed arguments, parse `message.text` yourself or build a small parser on top.

## Registration

When the bot starts, `TelegramEx.Server` calls:

```elixir
TelegramEx.Command.register_all(token, bot_module)
```

Registration:

1. reads `__commands__/0` from the bot module
2. reads `__commands__/0` from configured routers
3. deduplicates by command name
4. sends the list to Telegram with `setMyCommands`

This only updates the Telegram client menu. It does not change dispatch.
Dispatch still happens through generated `handle_message/2` clauses.

## Commands in Routers

Routers can define commands too:

```elixir
defmodule MyApp.CommandRouter do
  use TelegramEx.Router

  defcommand "status", description: "Show status", bind: [:ctx, :message] do
    ctx
    |> Message.text("OK")
    |> Message.send(message.chat["id"])
  end
end
```

Register the router in your bot:

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot, routers: [MyApp.CommandRouter]
end
```

Commands from routers are included in `setMyCommands`.

## Ordering

`defcommand/3` generates a regular `handle_message/2` clause. Normal Elixir
clause ordering applies:

```elixir
defcommand "start", description: "Start", bind: [:ctx, :message] do
  # specific command
end

def handle_message(%{text: text}, ctx) do
  # broad fallback
end
```

Put command handlers before broad text handlers. If a broad clause appears
first, it can catch `/start` before the generated command clause runs.

## Telegram Command Rules

Telegram command names should be short, lowercase command identifiers. Keep
names without `/`, avoid spaces, and use descriptions that explain the action in
one phrase. TelegramEx stores whatever you declare, but Telegram validates the
final `setMyCommands` request.

