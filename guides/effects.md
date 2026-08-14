# Effects

`TelegramEx.Effect` is the execution value used by builders. It keeps the
handler context and the first error produced by a builder step.

Most bot code does not create effects explicitly. A normal handler can still
start with `ctx`:

```elixir
ctx
|> Message.text("Hello")
|> Message.send(chat_id)
```

The first builder wraps `ctx` into an effect. Every following builder receives
that effect, updates it if it is successful, or leaves it unchanged if an error
has already happened.

## Shape of an Effect

Conceptually, an effect looks like this:

```elixir
%TelegramEx.Effect{
  ctx: ctx,
  result: nil,
  error: nil
}
```

- `:ctx` stores the current builder context
- `:error` stores the first failed step
- `:result` is used when an effect needs to carry a handler result

The important rule is simple: successful effects keep moving through the
pipeline; failed effects short-circuit later steps.

## Wrapping Context

`Effect.wrap/1` accepts either a context map or an existing effect:

```elixir
ctx = %{token: "123:token", payload: %{}}

effect = TelegramEx.Effect.wrap(ctx)

%TelegramEx.Effect{
  ctx: %{token: "123:token", payload: %{}},
  error: nil,
  result: nil
} = effect
```

This is why builders can accept both `ctx` and an effect:

```elixir
Message.text(ctx, "Hello")
Message.silent(Message.text(ctx, "Hello"))
```

Both calls return `TelegramEx.Effect`.

## Updating Context

Use `Effect.map_ctx/2` for steps that cannot fail. The function receives the
current context and must return the new context.

```elixir
alias TelegramEx.Effect

ctx = %{payload: %{}}

effect =
  ctx
  |> Effect.wrap()
  |> Effect.map_ctx(fn ctx ->
    payload = Map.put(ctx.payload, :text, "Hello")
    Map.put(ctx, :payload, payload)
  end)

%Effect{ctx: %{payload: %{text: "Hello"}}, error: nil} = effect
```

This is the mechanism behind payload-only builders such as `Message.text/2`,
`Message.silent/1`, and `Document.caption/2`.

## Running Fallible Steps

Use `Effect.then/2` for steps that can fail. The function receives the current
context and must return `{:ok, new_ctx}` or `{:error, reason}`.

```elixir
alias TelegramEx.Effect

read_file = fn ctx ->
  case File.read("/tmp/report.pdf") do
    {:ok, content} ->
      payload = Map.put(ctx.payload, :document, content)
      {:ok, Map.put(ctx, :payload, payload)}

    {:error, reason} ->
      {:error, {:file, reason}}
  end
end

effect =
  %{payload: %{}}
  |> Effect.wrap()
  |> Effect.then(read_file)
```

If the file exists, `effect.ctx.payload.document` contains the file content. If
the file cannot be read, `effect.error` is `{:file, reason}`.

Unexpected return values are treated as errors:

```elixir
effect =
  %{payload: %{}}
  |> Effect.wrap()
  |> Effect.then(fn ctx -> ctx end)

%Effect{error: {:invalid_return_value, %{payload: %{}}}} = effect
```

This keeps builder internals strict: a fallible step must say whether it
succeeded or failed.

## Short-Circuiting

After an error, `map_ctx/2` and `then/2` do not run their functions.

```elixir
alias TelegramEx.Effect

effect =
  %{payload: %{}}
  |> Effect.wrap()
  |> Effect.then(fn _ctx -> {:error, :missing_file} end)
  |> Effect.map_ctx(fn _ctx ->
    raise "this function is not called"
  end)
  |> Effect.then(fn _ctx ->
    raise "this function is not called either"
  end)

%Effect{error: :missing_file} = effect
```

This is the core reason builders can stay pipeline-friendly. A local file step
can fail, and later caption or send steps can remain in the code without adding
manual branching between every builder call.

## How Builders Use Effects

Payload builders usually delegate to `TelegramEx.Builder.put_payload/3`:

```elixir
def text(input, text) do
  TelegramEx.Builder.put_payload(input, :text, text)
end
```

`put_payload/3` wraps the input and updates `ctx.payload` through
`Effect.map_ctx/2`.

File builders delegate to `TelegramEx.Builder.put_file_payload/3`:

```elixir
def path(input, path) do
  TelegramEx.Builder.put_file_payload(input, :document, path)
end
```

`put_file_payload/3` uses `Effect.then/2`, because reading from disk can fail.
On failure it stores `{:file, reason}` in the effect.

Send builders also use `Effect.then/2`, because Telegram API requests can fail:

```elixir
def send(input, chat_id) do
  input
  |> Effect.wrap()
  |> Effect.then(fn ctx ->
    new_ctx =
      ctx
      |> Map.put(:chat_id, chat_id)
      |> Map.put(:method, "sendMessage")
      |> Map.put(:format, :json)

    case TelegramEx.API.request(new_ctx) do
      :ok -> {:ok, new_ctx}
      {:error, reason} -> {:error, reason}
    end
  end)
end
```

So a full builder chain is just a sequence of context transformations and
fallible steps inside one effect:

```elixir
ctx
|> Message.text("Report is ready")
|> Message.silent()
|> Message.send(chat_id)
```

## Returning Effects

Handlers may return an effect directly:

```elixir
def handle_message(%{text: "/start", chat: chat}, ctx) do
  ctx
  |> Message.text("Welcome!")
  |> Message.send(chat["id"])
end
```

Before processing the handler result, the server calls `Effect.to_result/1`:

```elixir
Effect.to_result(%Effect{error: nil, result: nil})
#=> :ok

Effect.to_result(%Effect{error: {:file, :enoent}})
#=> {:error, {:file, :enoent}}

Effect.to_result(:pass)
#=> :pass
```

That means effect-based builder pipelines and ordinary handler returns share
the same boundary. Successful sends become `:ok`; failed sends become
`{:error, reason}`; FSM return values still work normally.

## Explicit Handling

Return the effect directly when the server should handle logging. Use
`on_error/3` when the handler needs custom behavior at the end of a pipeline:

Modules that `use TelegramEx` can call `on_error/3`, `recover/3`, and
`recover_with/3` directly. If you call them through `TelegramEx.Effect`, require
the module first. The examples below assume this setup:

```elixir
alias TelegramEx.Effect
require Effect

ctx
|> Document.path("/tmp/monthly-report.pdf")
|> Document.caption("Monthly report")
|> Document.send(chat_id)
|> Effect.on_error({:file, _reason}, fn effect ->
  Logger.error("Could not read report for #{effect.ctx.chat_id}: #{inspect(effect.error)}")
end)
```

`on_error/3` returns the same effect unchanged. The callback is a side effect:
use it for logging, metrics, cleanup, or a fallback action that should not
replace the current effect. The callback may accept either no arguments or the
current effect.

The second argument is a pattern matched against the stored error. This lets a
handler react to one class of errors and leave the rest to the normal handler
result boundary:

```elixir
ctx
|> Document.path("/tmp/monthly-report.pdf")
|> Document.caption("Monthly report")
|> Document.send(chat_id)
|> Effect.on_error({:file, _reason}, fn effect ->
  Logger.error("File error: #{inspect(effect.error)}")
end)
|> Effect.on_error(%TelegramEx.Error{}, fn effect ->
  Logger.error("Telegram API error: #{inspect(effect.error)}")
end)
```

## Recovery

Use `recover/3` or `recover_with/3` when a failed effect should continue in the
middle of a pipeline.

`recover/3` clears a matching error and keeps the current context:

```elixir
ctx
|> Message.text("Profile updated.")
|> Effect.then(fn ctx ->
  case write_audit_log(ctx) do
    :ok -> {:ok, ctx}
    {:error, reason} -> {:error, {:audit_log, reason}}
  end
end)
|> Effect.recover({:audit_log, _reason}, fn effect ->
  Logger.warning("Audit log failed: #{inspect(effect.error)}")
  :ok
end)
|> Message.send(chat_id)
```

Use `recover_with/3` when recovery needs to replace the context:

```elixir
fallback_url = "https://example.com/reports/monthly.pdf"

ctx
|> Document.path("/tmp/monthly-report.pdf")
|> Effect.recover_with({:file, :enoent}, fn effect ->
  payload = Map.put(Map.get(effect.ctx, :payload, %{}), :document, fallback_url)
  {:ok, Map.put(effect.ctx, :payload, payload)}
end)
|> Document.caption("Monthly report")
|> Document.send(chat_id)
```

If the recovery function returns `{:error, reason}`, the effect remains failed
with the new reason. Unexpected return values are stored as
`{:invalid_return_value, value}`.
