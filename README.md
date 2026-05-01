<div align="center">
  
# TelegramEx

Elixir library for building Telegram bots with macro-based API.

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/lsdrfrx/telegram_ex/ci.yml?style=for-the-badge)
[![Hex Version](https://img.shields.io/hexpm/v/telegram_ex.svg?style=for-the-badge)](https://hex.pm/packages/telegram_ex)
![Last commit](https://img.shields.io/github/last-commit/lsdrfrx/telegram_ex?style=for-the-badge)
![Stars](https://img.shields.io/github/stars/lsdrfrx/telegram_ex?style=for-the-badge)
![License](https://img.shields.io/github/license/lsdrfrx/telegram_ex?style=for-the-badge)

</div>

## Why This Library Exists

I decided to create this library because I couldn't find anything in the existing Elixir ecosystem that I liked. Maybe I just didn't search well enough, but still.

What makes this library different? I like the macro-based implementation, similar to how `GenServer` works. It feels like the right approach for this kind of library, and I think others might appreciate it too.

## Installation

Add `telegram_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:telegram_ex, "~> 1.1.0"}
  ]
end
```

## Quick Start

Add the bot to your application's supervision tree:

```elixir
defmodule MyApp.Application do
  def start(_type, _args) do
    children = [MyBot]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
```

Create a bot module:

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot

  def handle_message(message, ctx) do
    # Handle incoming messages
  end

  def handle_callback(callback, ctx) do
    # Handle callback queries
    :ok
  end
end
```

Configure your bot token in `config/runtime.exs`:

```elixir
import Config

config :telegram_ex,
  my_bot: System.fetch_env!("MY_BOT_TELEGRAM_TOKEN")
```

## Key Features

### Pattern Matching on Messages

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot

  def handle_message(%{text: "/start", chat: chat}, ctx) do
    ctx
    |> Message.text("Welcome!")
    |> Message.send(chat["id"])
  end

  def handle_message(%{text: text, chat: chat}, ctx) do
    ctx
    |> Message.text("You said: #{text}")
    |> Message.send(chat["id"])
  end
end
```

### Stateful Conversations with FSM

Use `defstate/2` to build multi-step workflows:

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot

  def handle_message(%{text: "/start", chat: chat}, ctx) do
    ctx
    |> Message.text("What's your name?")
    |> Message.send(chat["id"])

    {:transition, :waiting_name}
  end

  defstate :waiting_name do
    def handle_message(%{text: name, chat: chat}, ctx) do
      ctx
      |> Message.text("Nice to meet you, #{name}!")
      |> Message.send(chat["id"])

      FSM.reset_state(:my_bot, chat["id"])
    end
  end
end
```

### Inline Keyboards

```elixir
def handle_message(%{chat: chat}, ctx) do
  keyboard = [[
    %{text: "Yes", callback_data: "yes"},
    %{text: "No", callback_data: "no"}
  ]]

  ctx
  |> Message.text("Do you agree?")
  |> Message.inline_keyboard(keyboard)
  |> Message.send(chat["id"])
end

def handle_callback(%{data: "yes"} = callback, ctx) do
  ctx
  |> Message.text("Great!")
  |> Message.answer_callback_query(callback)
  |> Message.send(callback.message.chat["id"])
end
```

### Sending Media

```elixir
# Photo
ctx
|> Photo.path("/path/to/image.jpg")
|> Photo.caption("Check this out!")
|> Photo.send(chat_id)

# Document
ctx
|> Document.url("https://example.com/file.pdf")
|> Document.send(chat_id)

# Video
ctx
|> Video.path("/path/to/video.mp4")
|> Video.duration(120)
|> Video.send(chat_id)
```

### Routers for Code Organization

Split your bot logic into separate modules:

```elixir
defmodule MyApp.AdminRouter do
  use TelegramEx.Router

  defstate :admin do
    def handle_message(%{text: "/exit", chat: chat}, ctx) do
      ctx
      |> Message.text("Exiting admin mode")
      |> Message.send(chat["id"])

      FSM.reset_state(:my_bot, chat["id"])
    end
  end
end

defmodule MyBot do
  use TelegramEx, name: :my_bot, routers: [MyApp.AdminRouter]
  # ...
end
```

## Documentation

For detailed documentation, see [HexDocs](https://hexdocs.pm/telegram_ex).

## Roadmap

### Sending Messages

- [x] Text messages
- [x] Photos (local & remote)
- [x] Documents (local & remote)
- [x] Stickers
- [x] Video
- [x] Location
- [ ] Polls
- [ ] Quizzes
- [x] Contacts

### Keyboards

- [x] Inline keyboard
- [x] Reply keyboard

### Message Management

- [ ] Edit message text
- [ ] Edit message caption
- [ ] Delete message

### Group Actions

- [ ] Get chat members
- [ ] Ban user
- [ ] Kick user
- [ ] Restrict user

### Chat Effects

- [ ] Typing indicator
- [ ] Recording voice indicator

### Integrations & Infrastructure

- [x] FSM
- [x] Forum topics
- [ ] Webhooks
- [ ] Middlewares
- [ ] Rate limiting
- [ ] Task scheduler
- [ ] Internationalization
- [ ] Backpex integration
- [x] Routers

<div align="center">
  <a href="https://www.star-history.com/?repos=lsdrfrx%2Ftelegram_ex&type=date&legend=top-left">
   <picture>
     <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/chart?repos=lsdrfrx/telegram_ex&type=date&theme=dark&legend=top-left" />
     <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/chart?repos=lsdrfrx/telegram_ex&type=date&legend=top-left" />
     <img alt="Star History Chart" src="https://api.star-history.com/chart?repos=lsdrfrx/telegram_ex&type=date&legend=top-left" />
   </picture>
  </a>
</div>
