defmodule TelegramEx do
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

      def handle_message(_message), do: :ok
      def handle_callback(_callback), do: :ok

      def transition_to(id, state) do
        State.set_current_state(id, state)
      end

      defoverridable handle_message: 1,
                     handle_callback: 1
    end
  end
end
