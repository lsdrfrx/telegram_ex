defmodule TelegramEx do
  @moduledoc """
  Entry point for building Telegram bots.

      defmodule MyBot do
        use TelegramEx, name: :my_bot

        def handle_message(%{text: "/start", chat: chat}) do
          Message.text("Hello!") |> Message.send(chat["id"])
        end
      end
  """

  @callback handle_message(message :: map()) :: any()
  @callback handle_callback(callback :: map()) :: any()

  defmacro __using__(opts) do
    quote do
      @behaviour TelegramEx

      import TelegramEx
      import TelegramEx.FSM, only: [defstate: 2]
      alias TelegramEx.{API, Config, FSM}
      alias TelegramEx.Builder.{Document, Location, Message, Photo, Sticker, Video}

      @bot_name Keyword.fetch!(unquote(opts), :name)

      def child_spec(_) do
        %{
          id: __MODULE__,
          start: {TelegramEx.Server, :start_link, [__MODULE__, @bot_name]},
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
