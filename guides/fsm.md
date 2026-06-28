# Finite State Machines

Telegram conversations often need memory: the bot asks a question, waits for an
answer, then asks the next question. TelegramEx stores per-chat state and data
to support these flows.

## State Storage

Each chat stores a `{state, data}` tuple:

- `state` is usually an atom such as `:waiting_name`
- `data` can be any Elixir term, commonly a map

```elixir
FSM.set_state(:my_bot, chat_id, :waiting_name, %{step: 1})
{state, data} = FSM.get_state(:my_bot, chat_id)
FSM.reset_state(:my_bot, chat_id)
```

The bot name identifies the ETS storage table. Use the same atom you pass to
`use TelegramEx, name: ...`.

## Starting a Flow

A normal handler can start a stateful flow by returning a transition:

```elixir
def handle_message(%{text: "/survey", chat: chat}, ctx) do
  ctx
  |> Message.text("What is your name?")
  |> Message.send(chat["id"])

  {:transition, :survey_name, %{}}
end
```

After this handler returns, TelegramEx stores `{:survey_name, %{}}` for that
chat.

## State Handlers

`defstate/2` makes handlers match only when `ctx.state` has the declared value:

```elixir
defstate :survey_name do
  def handle_message(%{text: name, chat: chat}, ctx) do
    ctx
    |> Message.text("How old are you?")
    |> Message.send(chat["id"])

    {:transition, :survey_age, Map.put(ctx.data, :name, name)}
  end
end
```

Conceptually, the handler is rewritten to match the state in the context:

```elixir
def handle_message(message, %{state: :survey_name} = ctx) do
  ...
end
```

This means state handlers are still normal function clauses. Ordering still
matters when multiple clauses could match.

## Complete Flow

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot

  def handle_message(%{text: "/survey", chat: chat}, ctx) do
    ctx
    |> Message.text("What is your name?")
    |> Message.send(chat["id"])

    {:transition, :survey_name, %{}}
  end

  defstate :survey_name do
    def handle_message(%{text: name, chat: chat}, ctx) do
      ctx
      |> Message.text("How old are you?")
      |> Message.send(chat["id"])

      {:transition, :survey_age, Map.put(ctx.data, :name, name)}
    end
  end

  defstate :survey_age do
    def handle_message(%{text: age_text, chat: chat}, ctx) do
      case Integer.parse(age_text) do
        {age, ""} when age > 0 ->
          ctx
          |> Message.text("Saved #{ctx.data.name}, age #{age}.")
          |> Message.send(chat["id"])

          FSM.reset_state(:my_bot, chat["id"])

        _ ->
          ctx
          |> Message.text("Please enter a valid age.")
          |> Message.send(chat["id"])

          :ok
      end
    end
  end
end
```

## Return Values

The server persists common FSM return values automatically:

- `{:transition, state}` - move to `state`, keep current data
- `{:transition, state, data}` - move to `state`, store `data`
- `{:stay, data}` - keep current state, replace data

Use `FSM.reset_state/2` when the flow is complete or cancelled.

## Cancellation

Long flows should usually support cancellation in every state:

```elixir
defstate :survey_age do
  def handle_message(%{text: "/cancel", chat: chat}, ctx) do
    ctx
    |> Message.text("Survey cancelled.")
    |> Message.send(chat["id"])

    FSM.reset_state(:my_bot, chat["id"])
  end
end
```

Put cancellation clauses before broad text clauses inside the same state.

## Routers and FSM

FSM works in routers as well as the main bot module. This is often the cleanest
shape for multi-step features: the main bot starts the flow, and a router owns
the state-specific handlers.

