# Getting Started

This guide walks through a minimal TelegramEx bot from dependency setup to a
running supervised process.

## 1. Install the Dependency

Add `telegram_ex` to `mix.exs`:

```elixir
def deps do
  [
    {:telegram_ex, "~> 1.2.0"}
  ]
end
```

Fetch dependencies:

```bash
mix deps.get
```

## 2. Configure the Token

Create or update `config/runtime.exs`:

```elixir
import Config

config :telegram_ex,
  my_bot: System.fetch_env!("MY_BOT_TELEGRAM_TOKEN")
```

The key `:my_bot` must match the `:name` used by your bot module.

## 3. Define the Bot

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

  def handle_callback(_callback, _ctx), do: :ok
end
```

`use TelegramEx` imports the builder modules, command helpers, FSM helpers, and
sets up the child spec used by the supervisor.

## 4. Start the Bot

Add the bot module to your application supervision tree:

```elixir
defmodule MyApp.Application do
  use Application

  def start(_type, _args) do
    children = [MyBot]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
```

Run the application with the token in the environment:

```bash
MY_BOT_TELEGRAM_TOKEN=123456:token mix run --no-halt
```

When the bot starts, TelegramEx:

1. reads the token with `TelegramEx.Config`
2. initializes FSM storage
3. registers commands collected by `defcommand/3`
4. starts long polling
5. dispatches incoming updates to handlers

## 5. Add a Button

Messages and callbacks are separate update types. Send an inline keyboard from a
message handler:

```elixir
def handle_message(%{text: "/confirm", chat: chat}, ctx) do
  keyboard = [[%{text: "Confirm", callback_data: "confirm"}]]

  ctx
  |> Message.text("Please confirm.")
  |> Message.inline_keyboard(keyboard)
  |> Message.send(chat["id"])
end
```

Handle the button press with `handle_callback/2`:

```elixir
def handle_callback(%{data: "confirm"} = callback, ctx) do
  ctx
  |> Message.text("Confirmed.")
  |> Message.answer_callback_query(callback)
  |> Message.send(callback.message.chat["id"])
end
```

## Next Steps

Read [Development Model](development.md) next if you want to understand how
handlers, context, routers, and return values fit together.

