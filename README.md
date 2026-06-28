# TelegramEx

Elixir library for building Telegram bots with a macro-based API.

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/lsdrfrx/telegram_ex/ci.yml?style=for-the-badge)
[![Hex Version](https://img.shields.io/hexpm/v/telegram_ex.svg?style=for-the-badge)](https://hex.pm/packages/telegram_ex)
![Last commit](https://img.shields.io/github/last-commit/lsdrfrx/telegram_ex?style=for-the-badge)
![Stars](https://img.shields.io/github/stars/lsdrfrx/telegram_ex?style=for-the-badge)
![License](https://img.shields.io/github/license/lsdrfrx/telegram_ex?style=for-the-badge)
![Hex.pm Downloads](https://img.shields.io/hexpm/dt/telegram_ex?style=for-the-badge)

## Installation

```elixir
def deps do
  [
    {:telegram_ex, "~> 1.2.0"}
  ]
end
```

## Quickstart

Configure your bot token in `config/runtime.exs`:

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

- [Getting Started](guides/getting-started.md)
- [Development Model](guides/development.md)
- [Commands](guides/commands.md)
- [Messages and Media](guides/messages-and-media.md)
- [Routers](guides/routers.md)
- [Finite State Machines](guides/fsm.md)
- [Examples](guides/examples.md)

## Features

- message and callback handlers with pattern matching
- command DSL with Telegram command menu registration
- fluent builders for messages, keyboards, media, polls, contacts, and locations
- router modules for organizing larger bots
- per-chat FSM state for multi-step conversations
- structured Telegram API errors

## Documentation

See [HexDocs](https://hexdocs.pm/telegram_ex) for API reference and guides.

<div align="center">
  <a href="https://www.star-history.com/?repos=lsdrfrx%2Ftelegram_ex&type=date&legend=top-left">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=lsdrfrx/telegram_ex&type=date&theme=dark&legend=top-left" />
      <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=lsdrfrx/telegram_ex&type=date&legend=top-left" />
      <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=lsdrfrx/telegram_ex&type=date&legend=top-left" />
    </picture>
  </a>
</div>
