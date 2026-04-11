defmodule TelegramEx.Router do
  @moduledoc false

  alias TelegramEx.Types

  @callback handle_message(message :: Types.Message.t()) :: any()
  @callback handle_callback(callback :: Types.CallbackQuery.t()) :: any()

  defmacro __using__(_opts) do
    quote do
      @behaviour TelegramEx.Router

      import TelegramEx
      import TelegramEx.FSM, only: [defstate: 2]
      alias TelegramEx.{API, Config, FSM}
      alias TelegramEx.Builder.{Document, Message, Photo}

      @before_compile TelegramEx.Router
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle_message(_message), do: :pass
      def handle_callback(_callback), do: :pass
    end
  end
end
