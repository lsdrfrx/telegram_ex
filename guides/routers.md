# Routers

Routers split a bot into smaller handler modules. They are useful when a bot has
separate areas: admin commands, surveys, onboarding, reports, or integrations.

## Defining a Router

```elixir
defmodule MyApp.AdminRouter do
  use TelegramEx.Router

  def handle_message(%{text: "/admin", chat: chat}, ctx) do
    ctx
    |> Message.text("Admin mode")
    |> Message.send(chat["id"])
  end
end
```

Register routers in the main bot:

```elixir
defmodule MyBot do
  use TelegramEx,
    name: :my_bot,
    routers: [MyApp.AdminRouter]
end
```

## Dispatch Chain

For each update, TelegramEx tries modules in this order:

1. router modules, left to right
2. the main bot module

Routers get default fallback handlers:

```elixir
def handle_message(_message, _ctx), do: :pass
def handle_callback(_callback, _ctx), do: :pass
```

`:pass` means "try the next router". Any other return value stops dispatch.

This makes router order meaningful:

```elixir
use TelegramEx,
  name: :my_bot,
  routers: [MyApp.AdminRouter, MyApp.PublicRouter]
```

If `AdminRouter` handles an update, `PublicRouter` will not see it. Keep broad
fallback clauses near the end of a router or in the main bot.

## Routers with FSM

Routers can define state-specific handlers:

```elixir
defmodule MyApp.SurveyRouter do
  use TelegramEx.Router

  defstate :survey_name do
    def handle_message(%{text: name, chat: chat}, ctx) do
      ctx
      |> Message.text("How old are you?")
      |> Message.send(chat["id"])

      {:transition, :survey_age, %{name: name}}
    end
  end

  defstate :survey_age do
    def handle_message(%{text: age, chat: chat}, ctx) do
      ctx
      |> Message.text("Saved #{ctx.data.name}, age #{age}.")
      |> Message.send(chat["id"])

      FSM.reset_state(:my_bot, chat["id"])
    end
  end
end
```

The main bot can start the flow:

```elixir
def handle_message(%{text: "/survey", chat: chat}, ctx) do
  ctx
  |> Message.text("What is your name?")
  |> Message.send(chat["id"])

  {:transition, :survey_name, %{}}
end
```

## Routers with Commands

Routers can define commands with `defcommand/3`:

```elixir
defmodule MyApp.CommandRouter do
  use TelegramEx.Router

  defcommand "echo", description: "Echo arguments", bind: [:ctx, :message, :args] do
    ctx
    |> Message.text(Enum.join(args, " "))
    |> Message.send(message.chat["id"])
  end
end
```

Commands from routers are included when TelegramEx registers commands with
Telegram. See [Commands](commands.md) for how this metadata is collected.

## When to Introduce Routers

Start with one bot module for small bots. Add routers when:

- one file starts mixing unrelated workflows
- a group of handlers shares an FSM flow
- a feature has its own callbacks and commands
- you want to test or reason about a feature independently

Routers are organizational. They do not create separate Telegram bots or
separate polling processes.

