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

### Echo Bot Example

```elixir
defmodule EchoBot do
  use TelegramEx,
    name: "echo_bot",
    token: "YOUR_BOT_TOKEN"

  def handle_message(message) do
    send_message(message["from"]["id"], message["text"])
  end
end
```