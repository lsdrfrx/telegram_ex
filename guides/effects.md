# Effects

TelegramEx builders return `TelegramEx.Effect`. An effect is a small execution
container that carries the current handler context plus an optional error or
result.

The goal is to keep the familiar builder pipeline while making failures
explicit and composable.

## Why Effects Exist

Some builder pipelines can fail before the Telegram API request is sent.

For example:

```elixir
ctx
|> Document.path("/tmp/report.pdf")
|> Document.caption("Report")
|> Document.send(chat_id)
```

There are two different failure points:

- `Document.path/2` reads a local file and can fail with `{:file, reason}`
- `Document.send/2` calls Telegram and can fail with an API error

Without an effect, every builder has to choose between raising, returning
`{:error, reason}`, or forcing callers to manually branch between every step.
Effects let the chain continue structurally while skipping later transformations
after the first error.

## Shape of an Effect

Conceptually, an effect looks like this:

```elixir
%TelegramEx.Effect{
  ctx: ctx,
  result: nil,
  error: nil
}
```

- `:ctx` is the current handler context
- `:error` stores the first failure in the chain
- `:result` is reserved for handler-level results

Most users do not need to construct effects manually. Builders call
`Effect.wrap/1`, so a pipeline can still start with the ordinary handler `ctx`.

```elixir
ctx
|> Message.text("Hello")
|> Message.send(chat_id)
```

The first builder lifts `ctx` into an effect. Every following builder receives
and returns an effect.

## Payload Steps

Payload-only builders use `Effect.map_ctx/2`. They run only when the effect has
no error.

```elixir
ctx
|> Message.text("Hello")
|> Message.silent()
```

Internally these steps update `ctx.payload`. If an earlier step failed, they are
skipped and the original error is preserved.

## Fallible Steps

Fallible builders use `Effect.then/2`. The function passed to `then/2` must
return either:

```elixir
{:ok, new_ctx}
{:error, reason}
```

Local file builders use this to report file errors:

```elixir
ctx
|> Photo.path("/missing/photo.jpg")
|> Photo.caption("This caption is skipped")
|> Photo.send(chat_id)
```

If the file cannot be read, the effect error becomes:

```elixir
{:file, reason}
```

The caption and send steps do not run.

## Sending Requests

`send/2` functions are also effect-aware. They add request metadata to the
context, call `TelegramEx.API.request/1`, and store any API error in the effect.

```elixir
ctx
|> Message.text("Done")
|> Message.send(chat_id)
```

On success, the effect keeps the request context. On failure, the effect stores
the API error.

## Returning Effects from Handlers

Handlers may return effects directly:

```elixir
def handle_message(%{text: "/start", chat: chat}, ctx) do
  ctx
  |> Message.text("Welcome!")
  |> Message.send(chat["id"])
end
```

`TelegramEx.Server` calls `Effect.to_result/1` before processing the handler
result. This means:

- successful effects become `:ok`
- failed effects become `{:error, reason}`
- ordinary FSM return values still work

The server remains responsible for FSM transitions and logging handler errors.

## Inspecting an Effect Explicitly

Most handlers can just return the effect. If you need explicit error handling,
match on the effect:

```elixir
case Document.path(ctx, "/tmp/report.pdf") |> Document.send(chat_id) do
  %TelegramEx.Effect{error: nil} ->
    :ok

  %TelegramEx.Effect{error: {:file, reason}} ->
    Logger.error("Could not read file: #{inspect(reason)}")

  %TelegramEx.Effect{error: reason} ->
    Logger.error("Could not send document: #{inspect(reason)}")
end
```

This is useful when a handler needs custom logging, retrying, cleanup, or a
fallback message.

## Effect Helpers

`Effect.wrap/1`

Converts a context map into an effect. If the input is already an effect, it is
returned unchanged.

`Effect.map_ctx/2`

Transforms the context when the effect is successful. If the effect already has
an error, it is returned unchanged.

`Effect.then/2`

Runs a fallible step when the effect is successful. The step must return
`{:ok, ctx}` or `{:error, reason}`. Unexpected return values become
`{:invalid_return_value, value}`.

`Effect.to_result/1`

Converts an effect back into a normal handler result for the server.

## Builder Helpers

`TelegramEx.Builder.put_payload/3` updates `ctx.payload` through an effect.

`TelegramEx.Builder.put_file_payload/3` reads a local file, builds multipart
payload metadata, and stores `{:file, reason}` if reading fails.

These helpers keep individual builders small and consistent.

