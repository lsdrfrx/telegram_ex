# Messages and Media

TelegramEx builders create Telegram API payloads through pipelines. A builder
does not send anything until the final `send/2` call.

## Builder Context

Every handler receives `ctx`. Builder functions add a `:payload` map and return
the updated context:

```elixir
ctx
|> Message.text("Hello")
|> Message.silent()
```

At this point the context contains enough payload data, but no HTTP request has
been made. `send/2` adds the target chat, method, and request format, then calls
`TelegramEx.API.request/1`.

## Text Messages

```elixir
def handle_message(%{text: "/start", chat: chat}, ctx) do
  ctx
  |> Message.text("Welcome!")
  |> Message.send(chat["id"])
end
```

Formatted text uses Telegram parse modes:

```elixir
ctx
|> Message.text("<b>Hello</b>", "HTML")
|> Message.send(chat_id)
```

```elixir
ctx
|> Message.text("*Hello*", "Markdown")
|> Message.send(chat_id)
```

Telegram validates formatting. Invalid HTML or Markdown can make the request
fail.

## Inline Keyboards

Inline keyboards are attached to a message and produce callback query updates:

```elixir
keyboard = [
  [
    %{text: "Approve", callback_data: "approve"},
    %{text: "Reject", callback_data: "reject"}
  ]
]

ctx
|> Message.text("Review request?")
|> Message.inline_keyboard(keyboard)
|> Message.send(chat_id)
```

Handle the callback with `handle_callback/2`:

```elixir
def handle_callback(%{data: "approve"} = callback, ctx) do
  ctx
  |> Message.text("Approved.")
  |> Message.answer_callback_query(callback)
  |> Message.send(callback.message.chat["id"])
end
```

Always answer callback queries. Telegram clients show a loading indicator after
button presses until the callback is acknowledged.

## Reply Keyboards

Reply keyboards replace the user's input keyboard with custom buttons:

```elixir
keyboard = [
  ["/help", "/settings"],
  ["/cancel"]
]

ctx
|> Message.text("Choose an action:")
|> Message.reply_keyboard(keyboard, resize_keyboard: true)
|> Message.send(chat_id)
```

Remove a reply keyboard explicitly:

```elixir
ctx
|> Message.text("Keyboard removed.")
|> Message.remove_keyboard()
|> Message.send(chat_id)
```

Use inline keyboards when you want callbacks. Use reply keyboards when you want
the user to send one of several text messages.

## Media Builders

Media builders follow the same pattern as `Message`.

Photo from URL:

```elixir
ctx
|> Photo.url("https://example.com/image.jpg")
|> Photo.caption("Remote photo")
|> Photo.send(chat_id)
```

Document from a local path:

```elixir
ctx
|> Document.path("/tmp/report.pdf")
|> Document.caption("Report")
|> Document.send(chat_id)
```

Video with duration:

```elixir
ctx
|> Video.path("/tmp/demo.mp4")
|> Video.duration(120)
|> Video.send(chat_id)
```

Poll:

```elixir
ctx
|> Poll.poll("Favorite color?", ["Red", "Blue", "Green"])
|> Poll.multiple_answers(true)
|> Poll.send(chat_id)
```

Quiz:

```elixir
ctx
|> Poll.quiz("What is 2 + 2?", ["3", "4", "5"], 1)
|> Poll.explanation("Correct answer is 4")
|> Poll.send(chat_id)
```

## Local Files and Request Formats

URL and Telegram file ID payloads are sent as normal values. Local files are read
from disk and sent as multipart data. Builders set the request format before
calling the API:

- text, polls, contacts, and locations use JSON
- photos, documents, stickers, and videos use multipart

For local media, TelegramEx uses `TelegramEx.MimeType` to infer the content type
from the file extension.

## Handling Send Results

`send/2` returns the API result:

```elixir
case Message.send(ctx, chat_id) do
  :ok ->
    :ok

  {:error, reason} ->
    Logger.error("Telegram request failed: #{inspect(reason)}")
end
```

Most examples return the `send/2` result directly. For production workflows,
handle failures where retrying or user feedback matters.

