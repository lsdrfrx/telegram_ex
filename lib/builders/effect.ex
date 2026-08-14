defmodule TelegramEx.Effect do
  @moduledoc """
  Execution container used by effect-aware builders.

  An effect carries the current handler context together with either an error or
  an optional result that can be converted back to a handler result with
  `to_result/1`.
  """

  @type t :: %__MODULE__{
          ctx: map(),
          result: term() | nil,
          error: term() | nil
        }

  defstruct [:ctx, :result, :error]

  def new(ctx) do
    %__MODULE__{ctx: ctx, result: nil, error: nil}
  end

  def wrap(%__MODULE__{} = effect), do: effect
  def wrap(ctx), do: new(ctx)

  def to_result(%__MODULE__{error: nil, result: nil}), do: :ok
  def to_result(%__MODULE__{error: nil, result: result}), do: result
  def to_result(%__MODULE__{error: reason}), do: {:error, reason}
  def to_result(result), do: result

  def map_ctx(%__MODULE__{ctx: ctx, error: nil} = effect, fun) when is_function(fun, 1) do
    %__MODULE__{effect | ctx: fun.(ctx)}
  end

  def map_ctx(%__MODULE__{} = effect, _fun), do: effect

  def then(%__MODULE__{ctx: ctx} = effect, fun) do
    case effect do
      %__MODULE__{error: nil} ->
        case fun.(ctx) do
          {:ok, new_ctx} -> %__MODULE__{effect | ctx: new_ctx}
          {:error, reason} -> %__MODULE__{effect | error: reason}
          unknown -> %__MODULE__{effect | error: {:invalid_return_value, unknown}}
        end

      _ ->
        effect
    end
  end

  @doc false
  def call_handler(fun, _effect) when is_function(fun, 0), do: fun.()
  def call_handler(fun, effect) when is_function(fun, 1), do: fun.(effect)

  @doc false
  def recover_result(%__MODULE__{} = effect, :ok), do: %__MODULE__{effect | error: nil}
  def recover_result(%__MODULE__{} = effect, {:ok, _}), do: %__MODULE__{effect | error: nil}

  def recover_result(%__MODULE__{} = effect, {:error, reason}) do
    %__MODULE__{effect | error: reason}
  end

  def recover_result(%__MODULE__{} = effect, unknown) do
    %__MODULE__{effect | error: {:invalid_return_value, unknown}}
  end

  @doc false
  def recover_with_result(%__MODULE__{} = effect, {:ok, ctx}) do
    %__MODULE__{effect | ctx: ctx, error: nil}
  end

  def recover_with_result(%__MODULE__{} = effect, {:error, reason}) do
    %__MODULE__{effect | error: reason}
  end

  def recover_with_result(%__MODULE__{} = effect, unknown) do
    %__MODULE__{effect | error: {:invalid_return_value, unknown}}
  end

  @doc """
  Runs a function when the effect contains a matching error.

  The function receives the current effect, or no arguments, and its return value
  is ignored. The original effect is always returned unchanged, so this macro is
  useful at the end of a builder pipeline for logging, metrics, cleanup, or
  fallback side effects.

  The second argument is an Elixir pattern matched against the stored error.

  ## Examples

      ctx
      |> Document.path("monthly-report.pdf")
      |> Document.caption("Monthly report")
      |> Document.send(chat_id)
      |> Effect.on_error({:file, _reason}, fn effect ->
        Logger.error("Could not read file: \#{inspect(effect.error)}")
      end)

      ctx
      |> Document.path("monthly-report.pdf")
      |> Document.send(chat_id)
      |> Effect.on_error({:file, _reason}, fn ->
        Logger.error("Could not read file")
      end)
  """
  defmacro on_error(effect, pattern, fun) do
    quote do
      effect = unquote(effect)

      case effect do
        %unquote(__MODULE__){error: unquote(pattern) = reason} when not is_nil(reason) ->
          unquote(__MODULE__).call_handler(unquote(fun), effect)

          effect

        %unquote(__MODULE__){} ->
          effect
      end
    end
  end

  @doc """
  Recovers a failed effect when its error matches the given pattern.

  The function receives the current effect, or no arguments, and must return
  `:ok`, `{:ok, value}`, or `{:error, reason}`. Successful return values clear
  the error and continue the pipeline with the current context. `{:error,
  reason}` replaces the stored error.

  Use `recover/3` when the pipeline can continue with the existing context. Use
  `recover_with/3` when recovery needs to replace the context.

  ## Examples

      ctx
      |> Message.text("Profile updated.")
      |> Effect.then(fn ctx ->
        case write_audit_log(ctx) do
          :ok -> {:ok, ctx}
          {:error, reason} -> {:error, {:audit_log, reason}}
        end
      end)
      |> Effect.recover({:audit_log, _reason}, fn effect ->
        Logger.warning("Audit log failed: \#{inspect(effect.error)}")
        :ok
      end)
      |> Message.send(chat_id)
  """
  defmacro recover(effect, pattern, fun) do
    quote do
      effect = unquote(effect)

      case effect do
        %unquote(__MODULE__){error: unquote(pattern) = reason} when not is_nil(reason) ->
          result = unquote(__MODULE__).call_handler(unquote(fun), effect)
          unquote(__MODULE__).recover_result(effect, result)

        %unquote(__MODULE__){} ->
          effect
      end
    end
  end

  @doc """
  Recovers a failed effect with a new context.

  The function receives the current effect, or no arguments, and must return
  `{:ok, new_ctx}` or `{:error, reason}`. On success, the effect continues with
  `new_ctx` and a cleared error. On error, the stored reason is replaced.

  ## Examples

      fallback_url = "https://example.com/reports/monthly.pdf"

      ctx
      |> Document.path("monthly-report.pdf")
      |> Effect.recover_with({:file, :enoent}, fn effect ->
        payload = Map.put(Map.get(effect.ctx, :payload, %{}), :document, fallback_url)
        {:ok, Map.put(effect.ctx, :payload, payload)}
      end)
      |> Document.caption("Monthly report")
      |> Document.send(chat_id)
  """
  defmacro recover_with(effect, pattern, fun) do
    quote do
      effect = unquote(effect)

      case effect do
        %unquote(__MODULE__){error: unquote(pattern) = reason} when not is_nil(reason) ->
          result = unquote(__MODULE__).call_handler(unquote(fun), effect)
          unquote(__MODULE__).recover_with_result(effect, result)

        %unquote(__MODULE__){} ->
          effect
      end
    end
  end
end
