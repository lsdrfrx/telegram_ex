<div align="center">

# TelegramEx

Elixir library for building Telegram bots with macro-based API.

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/lsdrfrx/telegram_ex/ci.yml?style=for-the-badge)
[![Hex Version](https://img.shields.io/hexpm/v/telegram_ex.svg?style=for-the-badge)](https://hex.pm/packages/telegram_ex)
![Last commit](https://img.shields.io/github/last-commit/lsdrfrx/telegram_ex?style=for-the-badge)
![Stars](https://img.shields.io/github/stars/lsdrfrx/telegram_ex?style=for-the-badge)
![License](https://img.shields.io/github/license/lsdrfrx/telegram_ex?style=for-the-badge)
![Hex.pm Downloads](https://img.shields.io/hexpm/dt/telegram_ex?style=for-the-badge)

</div>

## Why This Library Exists

I decided to create this library because I couldn't find anything in the existing Elixir ecosystem that I liked. Maybe I just didn't search well enough, but still.

What makes this library different? I like the macro-based implementation, similar to how `GenServer` works. It feels like the right approach for this kind of library, and I think others might appreciate it too.

## Installation

Add `telegram_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:telegram_ex, "~> 1.2.0"}
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

Handlers can return:

- `:ok` - keep the current state and data unchanged
- `{:stay, data}` - keep the current state and replace stored data
- `{:transition, state}` - change the current state and keep existing data
- `{:transition, state, data}` - change the current state and replace stored data
- `{:error, reason}` - log a handler error

## FSM API

You can interact with the FSM directly to read or manipulate state programmatically:

```elixir
alias TelegramEx.FSM

# Get current state and data for a user
{state, data} = FSM.get_state(:my_bot, chat_id)

# Set state only (keeps existing data)
FSM.set_state(:my_bot, chat_id, :waiting_input)

# Set state and replace data
FSM.set_state(:my_bot, chat_id, :waiting_input, %{retries: 0})

# Reset state (removes stored entry)
FSM.reset_state(:my_bot, chat_id)
```

## Sending Messages

Messages are sent using the `TelegramEx.Builder.Message` module. All builders follow a pipeline pattern, accepting `ctx` as the first argument:

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot

  def handle_message(%{chat: chat}, ctx) do
    ctx
    |> Message.text("Hello!")
    |> Message.send(chat["id"])
  end
end
```

### Message Builder Functions

- `Message.text(ctx, text)` - Create a text message
- `Message.text(ctx, text, parse_mode)` - Create a text message with parse mode (e.g., "Markdown", "HTML")
- `Message.inline_keyboard(ctx, keyboard)` - Add inline keyboard
- `Message.reply_keyboard(ctx, keyboard, opts)` - Add reply keyboard with options
- `Message.remove_keyboard(ctx)` - Remove custom keyboard
- `Message.silent(ctx)` - Send without notification
- `Message.answer_callback_query(ctx, callback)` - Answer callback query
- `Message.send(ctx, chat_id)` - Send the message

## Sending Photos

Use `TelegramEx.Builder.Photo` to send images:

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot

  def handle_message(%{chat: chat}, ctx) do
    ctx
    |> Photo.path("/path/to/image.jpg")
    |> Photo.caption("Here's a photo!")
    |> Photo.send(chat["id"])
  end
end
```

### Photo Builder Functions

- `Photo.url(ctx, url)` - Send photo from URL
- `Photo.path(ctx, path)` - Send photo from local file path
- `Photo.caption(ctx, caption)` - Add caption to photo
- `Photo.caption(ctx, caption, parse_mode)` - Add caption with parse mode
- `Photo.silent(ctx)` - Send without notification
- `Photo.send(ctx, chat_id)` - Send the photo

## Sending Documents

Use `TelegramEx.Builder.Document` to send files:

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot

  def handle_message(%{chat: chat}, ctx) do
    ctx
    |> Document.path("/path/to/file.pdf")
    |> Document.caption("Here's the document")
    |> Document.send(chat["id"])
  end
end
```

### Document Builder Functions

- `Document.url(ctx, url)` - Send document from URL
- `Document.path(ctx, path)` - Send document from local file path
- `Document.caption(ctx, caption)` - Add caption to document
- `Document.caption(ctx, caption, parse_mode)` - Add caption with parse mode
- `Document.silent(ctx)` - Send without notification
- `Document.send(ctx, chat_id)` - Send the document

## Sending Stickers

Use `TelegramEx.Builder.Sticker` to send stickers:

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot

  def handle_message(%{chat: chat}, ctx) do
    ctx
    |> Sticker.id("CAACAgIAAxkBA...")
    |> Sticker.send(chat["id"])
  end
end
```

### Sticker Builder Functions

- `Sticker.id(ctx, file_id)` - Send sticker by Telegram file ID
- `Sticker.url(ctx, url)` - Send sticker from URL
- `Sticker.path(ctx, path)` - Send sticker from local file path
- `Sticker.silent(ctx)` - Send without notification
- `Sticker.send(ctx, chat_id)` - Send the sticker

## Sending Videos

Use `TelegramEx.Builder.Video` to send videos:

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot

  def handle_message(%{chat: chat}, ctx) do
    ctx
    |> Video.path("/path/to/video.mp4")
    |> Video.duration(120)
    |> Video.cover_path("/path/to/cover.jpg")
    |> Video.send(chat["id"])
  end
end
```

### Video Builder Functions

- `Video.id(ctx, file_id)` - Send video by Telegram file ID
- `Video.url(ctx, url)` - Send video from URL
- `Video.path(ctx, path)` - Send video from local file path
- `Video.duration(ctx, seconds)` - Set video duration
- `Video.cover_path(ctx, path)` - Set cover image from local file
- `Video.cover_url(ctx, url)` - Set cover image from URL
- `Video.silent(ctx)` - Send without notification
- `Video.send(ctx, chat_id)` - Send the video

## Sending Locations

Use `TelegramEx.Builder.Location` to send geo coordinates:

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot

  def handle_message(%{chat: chat}, ctx) do
    ctx
    |> Location.coordinates(55.7558, 37.6173)
    |> Location.send(chat["id"])
  end
end
```

### Location Builder Functions

- `Location.coordinates(ctx, latitude, longitude)` - Set geo coordinates
- `Location.send(ctx, chat_id)` - Send the location

## Sending Contacts

Use `TelegramEx.Builder.Contact` to send contacts:

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot

  def handle_message(%{chat: chat}, ctx) do
    ctx
    |> Contact.contact("John", "+1234567890")
    |> Contact.send(chat["id"])
  end
end
```

## Sending Polls

Use `TelegramEx.Builder.Poll` to send polls and quizzes:

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot

  def handle_message(%{chat: chat}, ctx) do
    ctx
    |> Poll.poll("Favorite color?", ["Red", "Blue", "Green"])
    |> Poll.send(chat["id"])
  end
end
```

### Poll Builder Functions

- `Poll.poll(ctx, question, options)` – Create a regular poll
- `Poll.quiz(ctx, question, options, correct_option_id)` – Create a quiz (0‑based correct option index)
- `Poll.anonymous(ctx, boolean)` – Hide voter identities (default: true)
- `Poll.multiple_answers(ctx, boolean)` – Allow multiple answers (regular poll only)
- `Poll.explanation(ctx, text)` – Explanation for quiz (shown when answer is wrong)
- `Poll.explanation(ctx, text, parse_mode)` – Explanation with parse mode (e.g. `"Markdown"`, `"HTML"`)
- `Poll.open_period(ctx, seconds)` – Time in seconds the poll will be active
- `Poll.close_date(ctx, timestamp)` – Point in time (Unix timestamp) when poll will be closed
- `Poll.silent(ctx)` – Send without notification
- `Poll.send(ctx, chat_id)` – Send the poll

### Contact Builder Functions

- `Contact.contact(ctx, name, phone)` - Set first name and phone number
- `Contact.contact(ctx, first_name, last_name, phone)` - Set first name, last name, and phone number
- `Contact.silent(ctx)` - Send without notification
- `Contact.send(ctx, chat_id)` - Send the contact

### Keyboard Examples

**Inline Keyboard:**
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
