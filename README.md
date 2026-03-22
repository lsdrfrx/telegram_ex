<div align="center">
  
# TelegramEx

Elixir library for building Telegram bots. Provides a simple interface for handling messages, callbacks, and inline queries with automatic polling.

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

  def handle_message(message) do
    # Handle incoming messages
  end

  def handle_callback(callback) do
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

These handlers receive only the incoming update and do not depend on FSM state or stored data.

```elixir
defmodule MyBot do
  use TelegramEx

  def handle_message(%{text: "/start", chat: chat}) do
    Message.text("Welcome")
    |> Message.send(chat["id"])
  end

  def handle_callback(%{data: "ping", message: %{chat: chat}} = callback) do
    Message.text("pong")
    |> Message.answer_callback_query(callback)
    |> Message.send(chat["id"])
  end
end
```

Use this style when the handler does not need to remember anything between updates.

## Stateful Handlers

`defstate/2` is used when you want handlers to be selected by the current FSM state, with the state injected into pattern matching automatically. Regular handlers also can work with stored data via second argument (in this example, `data` argument), stateful handlers only use current state in pattern matching.

```elixir
defmodule MyBot do
  use TelegramEx

  def handle_message(%{text: "/start", chat: chat}) do
    Message.text("Welcome")
    |> Message.send(chat["id"])

    {:transition, :started, %{step: 1}}
  end

  defstate :started do
    def handle_message(%{text: text, chat: chat}, data) do
      Message.text("You said: #{text}")
      |> Message.send(chat["id"])

      {:stay, Map.put(data, :last_message, text)}
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

## Sending Messages

Messages are sent using the `TelegramEx.Builder.Message` module:

```elixir
defmodule MyBot do
  use TelegramEx

  def handle_message(%{chat: chat}) do
    Message.text("Hello!")
    |> Message.send(chat["id"])
  end
end
```

### Message Builder Functions

- `Message.text(text)` - Create a text message
- `Message.text(text, parse_mode)` - Create a text message with parse mode (e.g., "Markdown", "HTML")
- `Message.inline_keyboard(message, keyboard)` - Add inline keyboard
- `Message.reply_keyboard(message, keyboard, opts)` - Add reply keyboard with options
- `Message.remove_keyboard(message)` - Remove custom keyboard
- `Message.silent(message)` - Send without notification
- `Message.answer_callback_query(message, callback)` - Answer callback query
- `Message.send(message, chat_id)` - Send the message

## Sending Photos

Use `TelegramEx.Builder.Photo` to send images:

```elixir
defmodule MyBot do
  use TelegramEx

  def handle_message(%{chat: chat}) do
    Photo.path("/path/to/image.jpg")
    |> Photo.caption("Here's a photo!")
    |> Photo.send(chat["id"])
  end
end
```

### Photo Builder Functions

- `Photo.url(url)` - Send photo from URL
- `Photo.path(path)` - Send photo from local file path
- `Photo.caption(photo, caption)` - Add caption to photo
- `Photo.caption(photo, caption, parse_mode)` - Add caption with parse mode
- `Photo.silent(photo)` - Send without notification
- `Photo.send(photo, chat_id)` - Send the photo

## Sending Documents

Use `TelegramEx.Builder.Document` to send files:

```elixir
defmodule MyBot do
  use TelegramEx

  def handle_message(%{chat: chat}) do
    Document.path("/path/to/file.pdf")
    |> Document.caption("Here's the document")
    |> Document.send(chat["id"])
  end
end
```

### Document Builder Functions

- `Document.url(url)` - Send document from URL
- `Document.path(path)` - Send document from local file path
- `Document.caption(document, caption)` - Add caption to document
- `Document.caption(document, caption, parse_mode)` - Add caption with parse mode
- `Document.silent(document)` - Send without notification
- `Document.send(document, chat_id)` - Send the document

### Keyboard Examples

**Inline Keyboard:**

```elixir
def handle_message(%{chat: chat}) do
  keyboard = [[
    %{text: "Button 1", callback_data: "btn_1"},
    %{text: "Button 2", callback_data: "btn_2"}
  ]]

  Message.text("Choose an option:", "Markdown")
  |> Message.inline_keyboard(keyboard)
  |> Message.send(chat["id"])
end
```

**Reply Keyboard:**

```elixir
def handle_message(%{chat: chat}) do
  keyboard = [["/help", "/settings"], ["Contact"]]

  Message.text("Use the buttons below:")
  |> Message.reply_keyboard(keyboard, resize_keyboard: true, one_time_keyboard: true)
  |> Message.send(chat["id"])
end
```

**Reply Keyboard Options:**

- `resize_keyboard: true` - Request clients to resize the keyboard
- `one_time_keyboard: true` - Hide keyboard after first use

## Handling Callback Queries

When a user presses an inline keyboard button, `handle_callback/1` is called:

```elixir
def handle_callback(%{data: "btn_1"} = callback) do
  # Handle button 1 press
end

def handle_callback(%{data: "btn_2"} = callback) do
  # Handle button 2 press
end
```

### Answering Callback Queries

To show an alert or update the user after a callback:

```elixir
def handle_callback(%{data: data, chat: chat} = callback) do
  Message.text("Processed: #{data}")
  |> Message.answer_callback_query(callback)
  |> Message.send(chat["id"])
end

# Or simply answer callback without sending message
def handle_callback(callback) do
  Message.answer_callback_query(callback)
end
```

**Callback Query Structure:**

- `:id` - Unique identifier for the callback query
- `:from` - User who triggered the callback (map with string keys)
- `:message` - The message the callback was attached to
- `:inline_message_id` - Identifier of the inline message (if applicable)
- `:chat_instance` - Global identifier for the chat
- `:data` - Data associated with the callback button

## Message Structure

The `handle_message/1` callback receives a `%TelegramEx.Types.Message{}` struct with the following fields:

- `:message_id` - Unique message identifier
- `:from` - Sender information (map with string keys)
- `:chat` - Chat information (map with string keys)
- `:date` - Message date as Unix timestamp
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
  use TelegramEx

  def handle_message(%{text: text, chat: chat}) do
    Message.text("Echo: #{text}")
    |> Message.send(chat["id"])
  end
end
```

### Command Handling

```elixir
defmodule MyBot do
  use TelegramEx

  def handle_message(%{text: "/start", chat: chat}) do
    Message.text("Welcome! Send me any message.")
    |> Message.send(chat["id"])
  end

  def handle_message(%{text: text, chat: chat}) do
    Message.text("Echo: #{text}")
    |> Message.send(chat["id"])
  end
end
```
