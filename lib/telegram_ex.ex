defmodule TelegramEx do
  @callback handle_message(message :: map()) :: any()
  @callback handle_callback(callback :: map()) :: any()

  defmacro __using__(_opts) do
    quote do
      @behaviour TelegramEx

      import TelegramEx
      import TelegramEx.FSM, only: [defstate: 2]
      alias TelegramEx.{API, Config, FSM}
      alias TelegramEx.Builder.{Message, Photo, Document}

      def child_spec(_) do
        %{
          id: __MODULE__,
          start: {TelegramEx.Bot.Server, :start_link, [__MODULE__, Config.token()]},
          type: :worker
        }
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
