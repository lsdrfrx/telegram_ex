defmodule TelegramEx do
  @callback handle_message(message :: map()) :: any()
  @callback handle_callback(callback :: map()) :: any()

  defmacro defstate(state, do: block) do
    Macro.prewalk(block, fn
      {:def, def_meta, [func_header | rest]} ->
        {name, meta, args} = func_header
        new_args = args ++ [state]
        {:def, def_meta, [{name, meta, new_args} | rest]}

      other ->
        other
    end)
  end

  defmacro __using__(_opts) do
    quote do
      @behaviour TelegramEx

      import TelegramEx
      alias TelegramEx.{API, Config, State}
      alias TelegramEx.Builder.{Message, Photo, Document}

      def child_spec(_) do
        %{
          id: __MODULE__,
          start: {TelegramEx.Bot.Server, :start_link, [__MODULE__, Config.token()]},
          type: :worker
        }
      end

      def transition_to(id, state) do
        State.set_current_state(id, state)
      end

      @before_compile TelegramEx
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle_message(_message), do: :ok
      def handle_callback(_callback), do: :ok
    end
  end
end
