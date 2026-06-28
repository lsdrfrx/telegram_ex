# TelegramEx

TelegramEx is an Elixir library for building Telegram bots with pattern-matched
handlers, builder pipelines, routers, commands, and per-chat FSM state.

## Quickstart

Configure your token in `config/runtime.exs`:

```elixir
import Config

config :telegram_ex,
  my_bot: System.fetch_env!("MY_BOT_TELEGRAM_TOKEN")
```

Define a minimal bot:

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot

  def handle_message(%{text: "/start", chat: chat}, ctx) do
    ctx
    |> Message.text("Hello from TelegramEx.")
    |> Message.send(chat["id"])
  end

  def handle_callback(_callback, _ctx), do: :ok
end
```

Start it under your supervision tree:

```elixir
children = [MyBot]
Supervisor.start_link(children, strategy: :one_for_one)
```

## Guides

- [Getting Started](getting-started.md)
- [Development Model](development.md)
- [Commands](commands.md)
- [Messages and Media](messages-and-media.md)
- [Routers](routers.md)
- [Finite State Machines](fsm.md)
- [Examples](examples.md)

## Features

- message and callback handlers with pattern matching
- command DSL with Telegram command menu registration
- fluent builders for messages, keyboards, media, polls, contacts, and locations
- router modules for organizing larger bots
- per-chat FSM state for multi-step conversations
- structured Telegram API errors

