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
end
