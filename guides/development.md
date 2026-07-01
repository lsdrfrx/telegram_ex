# Development Model

TelegramEx applications are built around handler modules. A handler module is a
regular Elixir module that receives parsed Telegram updates and decides what to
send back.

## Bot Modules

A bot module starts with `use TelegramEx`:

```elixir
defmodule MyBot do
  use TelegramEx, name: :my_bot
end
```

The `:name` value is important. TelegramEx uses it to:

- read the bot token from application config
- create FSM storage for that bot
- name the polling server process

For this bot, the token is read from:

```elixir
config :telegram_ex,
  my_bot: "123456:token"
```

## Messages

Telegram sends ordinary user messages as `message` updates. TelegramEx parses
them into `TelegramEx.Types.Message` structs and calls `handle_message/2`.

```elixir
def handle_message(%{text: "/start", chat: chat}, ctx) do
  ctx
  |> Message.text("Welcome!")
  |> Message.send(chat["id"])
end
```

Handlers are just Elixir function clauses. Pattern matching is the main routing
tool:

```elixir
def handle_message(%{text: "/help", chat: chat}, ctx) do
  ctx
  |> Message.text("Available commands: /start, /help")
  |> Message.send(chat["id"])
end

def handle_message(%{text: text, chat: chat}, ctx) do
  ctx
  |> Message.text("You said: #{text}")
  |> Message.send(chat["id"])
end
```

Clause order matters. Put specific handlers before broad handlers.

## Callback Queries

Inline keyboard buttons do not arrive as messages. They arrive as callback
queries and are handled by `handle_callback/2`.

```elixir
def handle_message(%{text: "/confirm", chat: chat}, ctx) do
  keyboard = [[%{text: "Confirm", callback_data: "confirm"}]]

  ctx
  |> Message.text("Please confirm.")
  |> Message.inline_keyboard(keyboard)
  |> Message.send(chat["id"])
end

def handle_callback(%{data: "confirm"} = callback, ctx) do
  ctx
  |> Message.text("Confirmed.")
  |> Message.answer_callback_query(callback)
  |> Message.send(callback.message.chat["id"])
end
```

`Message.answer_callback_query/2` acknowledges the button press so Telegram
clients stop showing the loading state.

## Context

The second handler argument is a context map. It is created for each update and
is also used by builder pipelines.

The server puts these keys into the context:

- `:token` - bot token used by API requests
- `:state` - current FSM state for the chat, or `nil`
- `:data` - current FSM data for the chat, or `nil`
- `:message_thread_id` - present for forum topic messages

Builders add request data to the same map:

- `:payload` - Telegram API payload under construction
- `:chat_id` - target chat
- `:method` - Telegram API method, such as `"sendMessage"`
- `:format` - `:json` or `:multipart`

This is why builders compose naturally:

```elixir
ctx
|> Message.text("Hello")
|> Message.silent()
|> Message.send(chat_id)
```

Builder steps do not mutate the original map directly. They wrap the context in
`TelegramEx.Effect`, store payload data inside that effect, and keep passing the
effect through the pipeline. The final `send/2` step turns the accumulated
context into a Telegram API request and stores any error in the effect.

Most handlers do not need to manage effects manually. Returning the builder
pipeline is enough; the server converts successful effects to `:ok` and failed
effects to `{:error, reason}`. See [Effects](effects.md) for the detailed model.

## Return Values

Most simple handlers return the effect produced by a builder pipeline:

```elixir
def handle_message(%{text: "/start", chat: chat}, ctx) do
  ctx
  |> Message.text("Welcome!")
  |> Message.send(chat["id"])
end
```

The server also accepts ordinary handler results.

FSM-aware handlers can return transition values:

- `{:transition, state}` - move to `state`, keep current data
- `{:transition, state, data}` - move to `state`, store `data`
- `{:stay, data}` - keep current state, replace data

Routers can return `:pass` to let the next router or the main bot module try the
update.

## Dispatch Flow

For each update, TelegramEx:

1. parses the raw Telegram payload into a struct
2. loads FSM state and data for the chat
3. builds the handler context
4. tries routers in order
5. tries the main bot module
6. converts effects to handler results
7. applies FSM transition return values

This keeps application code small: handlers describe behavior, while the server
handles polling, parsing, context setup, and state persistence.
