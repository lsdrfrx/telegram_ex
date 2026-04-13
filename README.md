<div align="center">
  
# TelegramEx

Elixir library for building Telegram bots. Provides a simple interface for handling messages, callbacks, and inline queries with automatic polling.

![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/lsdrfrx/telegram_ex/ci.yml?style=for-the-badge)
[![Hex Version](https://img.shields.io/hexpm/v/telegram_ex.svg?style=for-the-badge)](https://hex.pm/packages/telegram_ex)
![Last commit](https://img.shields.io/github/last-commit/lsdrfrx/telegram_ex?style=for-the-badge)
![Stars](https://img.shields.io/github/stars/lsdrfrx/telegram_ex?style=for-the-badge)
![License](https://img.shields.io/github/license/lsdrfrx/telegram_ex?style=for-the-badge)

</div>

## Why This Library Exists

I decided to create this library because I couldn't find anything in the existing Elixir ecosystem that I liked. Maybe I just didn't search well enough, but still.

What makes this library different? I like the macro-based implementation, similar to how `GenServer` works. It feels like the right approach for this kind of library, and I think others might appreciate it too.

## Usage

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

Add your bot token to `config/runtime.exs`:

```elixir
import Config

config :telegram_ex,
  my_bot: System.fetch_env!("MY_BOT_TELEGRAM_TOKEN")
```

## Stateless Handlers

These handlers receive the incoming update and a context map (`ctx`). The context carries the bot token, FSM state, and is used as a pipeline accumulator for builders.

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot

  def handle_message(%{text: "/start", chat: chat}, ctx) do
    ctx
    |> Message.text("Welcome")
    |> Message.send(chat["id"])
  end

  def handle_callback(%{data: "ping", message: %{chat: chat}} = callback, ctx) do
    ctx
    |> Message.text("pong")
    |> Message.answer_callback_query(callback)
    |> Message.send(chat["id"])
  end
end
```

Use this style when the handler does not need to remember anything between updates.

## Stateful Handlers

`defstate/2` is used when you want handlers to be selected by the current FSM state, with the state injected into pattern matching automatically. The second argument of the handler is `ctx`, which contains `:state`, `:data`, and `:token`.

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot

  def handle_message(%{text: "/start", chat: chat}, ctx) do
    ctx
    |> Message.text("Welcome")
    |> Message.send(chat["id"])

    {:transition, :started, %{step: 1}}
  end

  defstate :started do
    def handle_message(%{text: text, chat: chat}, ctx) do
      ctx
      |> Message.text("You said: #{text}")
      |> Message.send(chat["id"])

      {:stay, Map.put(ctx.data, :last_message, text)}
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

### Contact Builder Functions

- `Contact.contact(ctx, name, phone)` - Set first name and phone number
- `Contact.contact(ctx, first_name, last_name, phone)` - Set first name, last name, and phone number
- `Contact.silent(ctx)` - Send without notification
- `Contact.send(ctx, chat_id)` - Send the contact

### Keyboard Examples

**Inline Keyboard:**

```elixir
def handle_message(%{chat: chat}, ctx) do
  keyboard = [[
    %{text: "Button 1", callback_data: "btn_1"},
    %{text: "Button 2", callback_data: "btn_2"}
  ]]

  ctx
  |> Message.text("Choose an option:", "Markdown")
  |> Message.inline_keyboard(keyboard)
  |> Message.send(chat["id"])
end
```

**Reply Keyboard:**

```elixir
def handle_message(%{chat: chat}, ctx) do
  keyboard = [["/help", "/settings"], ["Contact"]]

  ctx
  |> Message.text("Use the buttons below:")
  |> Message.reply_keyboard(keyboard, resize_keyboard: true, one_time_keyboard: true)
  |> Message.send(chat["id"])
end
```

**Reply Keyboard Options:**

- `resize_keyboard: true` - Request clients to resize the keyboard
- `one_time_keyboard: true` - Hide keyboard after first use

## Handling Callback Queries

When a user presses an inline keyboard button, `handle_callback/2` is called with a `%TelegramEx.Types.CallbackQuery{}` struct and `ctx`:

```elixir
def handle_callback(%{data: "btn_1"} = callback, ctx) do
  # Handle button 1 press
end

def handle_callback(%{data: "btn_2"} = callback, ctx) do
  # Handle button 2 press
end
```

### Answering Callback Queries

To show an alert or update the user after a callback:

```elixir
def handle_callback(%{data: data, message: %{chat: chat}} = callback, ctx) do
  ctx
  |> Message.text("Processed: #{data}")
  |> Message.answer_callback_query(callback)
  |> Message.send(chat["id"])
end
```

**Callback Query Structure** (`%TelegramEx.Types.CallbackQuery{}`):

- `:id` - Unique identifier for the callback query
- `:from` - User who triggered the callback (map with string keys)
- `:message` - The `%TelegramEx.Types.Message{}` the callback was attached to
- `:inline_message_id` - Identifier of the inline message (if applicable)
- `:chat_instance` - Global identifier for the chat
- `:data` - Data associated with the callback button

## Message Structure

The `handle_message/2` callback receives a `%TelegramEx.Types.Message{}` struct and a `ctx` map with the following fields:

- `:message_id` - Unique message identifier
- `:from` - Sender information (map with string keys)
- `:chat` - Chat information (map with string keys)
- `:date` - Message date as Unix timestamp
- `:message_thread_id` - Thread identifier in forum chats (if any)
- `:text` - Message text content
- `:photo` - Photo attachments (if any)
- `:document` - Document attachment (if any)
- `:sticker` - Sticker (if any)
- `:video` - Video (if any)
- `:voice` - Voice message (if any)
- `:caption` - Caption for media

## Examples

### Echo Bot

```elixir
defmodule EchoBot do
  use TelegramEx, name: :echo_bot

  def handle_message(%{text: text, chat: chat}, ctx) do
    ctx
    |> Message.text("Echo: #{text}")
    |> Message.send(chat["id"])
  end
end
```

### Command Handling

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot

  def handle_message(%{text: "/start", chat: chat}, ctx) do
    ctx
    |> Message.text("Welcome! Send me any message.")
    |> Message.send(chat["id"])
  end

  def handle_message(%{text: text, chat: chat}, ctx) do
    ctx
    |> Message.text("Echo: #{text}")
    |> Message.send(chat["id"])
  end
end
```

## Routers

Use `TelegramEx.Router` to group handlers by logic into separate modules. This keeps the main bot module clean and lets you organize handlers by domain.

```elixir
defmodule MyApp.Routers.Admin do
  use TelegramEx.Router

  defstate :admin do
    def handle_message(%{text: "/exit", chat: chat}, ctx) do
      ctx
      |> Message.text("Exiting admin mode")
      |> Message.send(chat["id"])

      FSM.reset_state(:my_bot, chat["id"])
    end

    def handle_message(%{text: text, chat: chat}, ctx) do
      ctx
      |> Message.text("Admin command: #{text}")
      |> Message.send(chat["id"])
    end
  end
end
```

Register routers in the main bot module:

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot, routers: [MyApp.Routers.Admin]

  def handle_message(%{text: "/admin", chat: chat}, ctx) do
    ctx
    |> Message.text("Entering admin mode")
    |> Message.send(chat["id"])

    {:transition, :admin}
  end
end
```

Routers are checked in order before the main bot module. If a router's handler returns `:pass`, the next router (or the bot module) is tried.

## Forum Topics

When replying to messages from forum chats (topics/threads), `message_thread_id` is handled automatically. The library injects it from the incoming message into the outgoing payload, so replies are sent to the correct thread without any extra code.

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
