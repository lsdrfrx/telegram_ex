# TelegramEx

Elixir library for building Telegram bots. Provides a simple interface for handling messages, callbacks, and inline queries with automatic polling.

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
  use TelegramEx,
    name: "my_bot",
    token: "YOUR_BOT_TOKEN"

  def handle_message(message) do
    # Handle incoming messages
  end

  def handle_callback(callback) do
    # Handle callback queries
    :ok
  end

  def handle_inline(inline) do
    # Handle inline queries
    :ok
  end
end
```

## Sending Messages

Messages are sent using the `TelegramEx.Builder.Message` module:

```elixir
defmodule MyBot do
  use TelegramEx,
    name: "my_bot",
    token: "YOUR_BOT_TOKEN"

  def handle_message(%{chat: chat}) do
    Message.new(chat["id"])
    |> Message.text("Hello!")
    |> Message.send(@bot_token)
  end
end
```

### Builder Functions

- `Message.new(chat_id)` - Create a new message for a chat
- `Message.text(message, text)` - Set message text
- `Message.text(message, text, parse_mode)` - Set text with parse mode (e.g., "Markdown", "HTML")
- `Message.inline_keyboard(message, keyboard)` - Add inline keyboard
- `Message.reply_keyboard(message, keyboard, opts)` - Add reply keyboard with options
- `Message.remove_keyboard(message)` - Remove custom keyboard
- `Message.silent(message)` - Send without notification
- `Message.answer_callback_query(message, callback, token)` - Answer callback query

### Keyboard Examples

**Inline Keyboard:**

```elixir
def handle_message(%TelegramEx.Types.Message{chat: chat}) do
  keyboard = [[
    %{text: "Button 1", callback_data: "btn_1"},
    %{text: "Button 2", callback_data: "btn_2"}
  ]]

  Message.new(chat["id"])
  |> Message.text("Choose an option:", "Markdown")
  |> Message.inline_keyboard(keyboard)
  |> Message.send(@bot_token)
end
```

**Reply Keyboard:**

```elixir
def handle_message(%TelegramEx.Types.Message{chat: chat}) do
  keyboard = [["/help", "/settings"], ["Contact"]]

  Message.new(chat["id"])
  |> Message.text("Use the buttons below:")
  |> Message.reply_keyboard(keyboard, resize_keyboard: true, one_time_keyboard: true)
  |> Message.send(@bot_token)
end
```

**Reply Keyboard Options:**

- `resize_keyboard: true` - Request clients to resize the keyboard
- `one_time_keyboard: true` - Hide keyboard after first use
- `selective: true` - Show keyboard to specific users only

## Handling Callback Queries

When a user presses an inline keyboard button, `handle_callback/1` is called:

```elixir
def handle_callback(%{data: "btn_1", id: callback_id} = callback) do
  # Handle button 1 press
end

def handle_callback(%{data: "btn_2", id: callback_id} = callback) do
  # Handle button 2 press
end
```

### Answering Callback Queries

To show an alert or update the user after a callback:

```elixir
def handle_callback(%{data: data, id: callback_id} = callback) do
  Message.new(nil)
  |> Message.answer_callback_query(callback, @bot_token)
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
  use TelegramEx,
    name: "echo_bot",
    token: "YOUR_BOT_TOKEN"

  def handle_message(%{text: text, chat: chat}) do
    Message.new(chat["id"])
    |> Message.text("Echo: #{text}")
    |> Message.send(@bot_token)
  end
end
```

### Command Handling

```elixir
defmodule MyBot do
  use TelegramEx,
    name: "my_bot",
    token: "YOUR_BOT_TOKEN"

  def handle_message(%{text: "/start", chat: chat}) do
    Message.new(chat["id"])
    |> Message.text("Welcome! Send me any message.")
    |> Message.send(@bot_token)
  end

  def handle_message(%{text: text, chat: chat}) do
    Message.new(chat["id"])
    |> Message.text("Echo: #{text}")
    |> Message.send(@bot_token)
  end
end
```
