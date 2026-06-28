defmodule TelegramEx.Router do
  @moduledoc """
  Behaviour for organizing bot handlers into separate modules.

  Routers are tried before the main bot module and can define message handlers,
  callback handlers, FSM states, and commands. See [Routers](routers.md).
  """

  alias TelegramEx.Types

  @doc """
  Callback invoked when a message is received.

  Should return a `TelegramEx.handler_result()` or `:pass` to skip to the next handler.
  """
  @callback handle_message(message :: Types.Message.t(), ctx :: map()) :: any()

  @doc """
  Callback invoked when a callback query is received.

  Should return a `TelegramEx.handler_result()` or `:pass` to skip to the next handler.
  """
  @callback handle_callback(callback :: Types.CallbackQuery.t(), ctx :: map()) :: any()

  defmacro __using__(_opts) do
    quote do
      @behaviour TelegramEx.Router

      import TelegramEx
      import TelegramEx.FSM, only: [defstate: 2]
      import TelegramEx.Command, only: [defcommand: 3]
      alias TelegramEx.{API, Config, FSM}
      alias TelegramEx.Builder.{Contact, Document, Location, Message, Photo, Poll, Sticker, Video}

      Module.register_attribute(__MODULE__, :commands, accumulate: true)

      @before_compile TelegramEx.Router
    end
  end

  defmacro __before_compile__(env) do
    commands =
      env.module
      |> Module.get_attribute(:commands)
      |> Enum.reverse()

    quote do
      def __commands__, do: unquote(Macro.escape(commands))
      def handle_message(_message, _ctx), do: :pass
      def handle_callback(_callback, _ctx), do: :pass
    end
  end
end
