# Examples

This page collects short, focused examples that show common TelegramEx patterns
in context.

## Echo Bot

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

This is the smallest useful shape: pattern match a message, use a builder, send
the response.

## Start Command with Reply Keyboard

```elixir
def handle_message(%{text: "/start", chat: chat}, ctx) do
  keyboard = [
    ["/help", "/status"],
    ["/cancel"]
  ]

  ctx
  |> Message.text("Choose an action.")
  |> Message.reply_keyboard(keyboard, resize_keyboard: true)
  |> Message.send(chat["id"])
end
```

Reply keyboards send text messages back to the bot. Handle those button labels
with normal `handle_message/2` clauses.

## Inline Confirmation

```elixir
def handle_message(%{text: "/delete", chat: chat}, ctx) do
  keyboard = [[
    %{text: "Delete", callback_data: "delete:yes"},
    %{text: "Cancel", callback_data: "delete:no"}
  ]]

  ctx
  |> Message.text("Delete this item?")
  |> Message.inline_keyboard(keyboard)
  |> Message.send(chat["id"])
end

def handle_callback(%{data: "delete:yes"} = callback, ctx) do
  ctx
  |> Message.text("Deleted.")
  |> Message.answer_callback_query(callback)
  |> Message.send(callback.message.chat["id"])
end

def handle_callback(%{data: "delete:no"} = callback, ctx) do
  ctx
  |> Message.text("Cancelled.")
  |> Message.answer_callback_query(callback)
  |> Message.send(callback.message.chat["id"])
end
```

Inline keyboards are better than reply keyboards when the button press should be
handled as an action rather than as user text.

## Command with Arguments

```elixir
defcommand "remind", description: "Create a reminder", bind: [:ctx, :message, :args] do
  case args do
    [delay | text_parts] when text_parts != [] ->
      text = Enum.join(text_parts, " ")

      ctx
      |> Message.text("Reminder set for #{delay}: #{text}")
      |> Message.send(message.chat["id"])

    _ ->
      ctx
      |> Message.text("Usage: /remind 10m drink water")
      |> Message.send(message.chat["id"])
  end
end
```

`defcommand/3` handles command dispatch and metadata registration. Argument
validation remains application code.

## Send Local Media

```elixir
def handle_message(%{text: "/report", chat: chat}, ctx) do
  ctx
  |> Document.path("/tmp/report.pdf")
  |> Document.caption("Latest report")
  |> Document.send(chat["id"])
end
```

Local media builders read the file and send multipart requests.

## Multi-Step Survey

```elixir
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

    {:transition, :survey_age, %{name: name}}
  end
end

defstate :survey_age do
  def handle_message(%{text: age, chat: chat}, ctx) do
    ctx
    |> Message.text("Thanks #{ctx.data.name}. Age saved: #{age}.")
    |> Message.send(chat["id"])

    FSM.reset_state(:my_bot, chat["id"])
  end
end
```

FSM is useful when the next valid handler depends on previous user input.

## Feature Router

```elixir
defmodule MyApp.ReportRouter do
  use TelegramEx.Router

  defcommand "report", description: "Send report", bind: [:ctx, :message] do
    ctx
    |> Message.text("Report is being generated.")
    |> Message.send(message.chat["id"])
  end
end

defmodule MyBot do
  use TelegramEx, name: :my_bot, routers: [MyApp.ReportRouter]
end
```

Routers keep feature-specific commands, callbacks, and FSM states together.

## Handling Builder Errors

```elixir
case Message.send(ctx, chat_id) do
  %TelegramEx.Effect{error: nil} ->
    :ok

  %TelegramEx.Effect{error: %TelegramEx.Error{description: description}} ->
    Logger.error("Telegram API error: #{description}")

  %TelegramEx.Effect{error: reason} ->
    Logger.error("Request failed: #{inspect(reason)}")
end
```

Most examples return the effect from `send/2` directly, but explicit handling is
useful for retries, logging, cleanup, and user-facing fallback messages.

```elixir
case Document.path(ctx, "/tmp/report.pdf") |> Document.send(chat_id) do
  %TelegramEx.Effect{error: nil} ->
    :ok

  %TelegramEx.Effect{error: {:file, reason}} ->
    Logger.error("Could not open report: #{inspect(reason)}")

  %TelegramEx.Effect{error: reason} ->
    Logger.error("Could not send report: #{inspect(reason)}")
end
```
