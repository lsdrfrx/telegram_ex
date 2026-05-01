defmodule TelegramEx.Router do
  @moduledoc """
  Behaviour for organizing bot handlers into separate modules.

  Routers allow you to split your bot's logic into multiple modules,
  each handling specific domains or features. This keeps your main bot
  module clean and makes large bots more maintainable.

  ## Usage

  Create a router module:

      defmodule MyApp.Routers.Admin do
        use TelegramEx.Router

        defstate :admin do
          def handle_message(%{text: "/exit", chat: chat}, ctx) do
            ctx
            |> Message.text("Exiting admin mode")
            |> Message.send(chat["id"])

            FSM.reset_state(:my_bot, chat["id"])
          end

          def handle_message(%{text: text, chat: chat}, ctx) do
            ctx
            |> Message.text("Admin command: \#{text}")
            |> Message.send(chat["id"])
          end
        end

        def handle_callback(_callback, _ctx), do: :pass
      end

  Register the router in your bot:

      defmodule MyBot do
        use TelegramEx, name: :my_bot, routers: [MyApp.Routers.Admin]

        def handle_message(%{text: "/admin", chat: chat}, ctx) do
          ctx
          |> Message.text("Entering admin mode")
          |> Message.send(chat["id"])

          {:transition, :admin}
        end
      end

  ## Handler Chain

  When an update arrives, routers are tried in the order they're listed.
  If a router returns `:pass`, the next router (or main bot module) is tried.
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
