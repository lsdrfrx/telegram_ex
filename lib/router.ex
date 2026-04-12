defmodule TelegramEx.Router do
  @moduledoc false

  alias TelegramEx.Types

  @callback handle_message(message :: Types.Message.t(), ctx :: map()) :: any()
  @callback handle_callback(callback :: Types.CallbackQuery.t(), ctx :: map()) :: any()

  defmacro __using__(_opts) do
    quote do
      @behaviour TelegramEx.Router

      import TelegramEx
      import TelegramEx.FSM, only: [defstate: 2]
      alias TelegramEx.{API, Config, FSM}
      alias TelegramEx.Builder.{Contact, Document, Location, Message, Photo, Sticker, Video}

      @before_compile TelegramEx.Router
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def handle_message(_message, _ctx), do: :pass
      def handle_callback(_callback, _ctx), do: :pass
    end
  end
end
