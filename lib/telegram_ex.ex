defmodule TelegramEx do
  @moduledoc """
  Defines a behaviour for Telegram bots and provides the main `use` macro.

  `use TelegramEx` sets up callbacks, imports common helpers, registers the bot
  child spec, and adds fallback handlers.

  ## Macro Options

  - `:name` (required) - bot identifier used for config lookup and FSM storage
  - `:routers` (optional) - router modules tried before the bot module

  See [Getting Started](getting-started.md) for setup and supervision examples,
  and [Effects](effects.md) for builder pipeline error handling.
  """

  alias TelegramEx.Types

  @typedoc """
  Context map passed to all handlers.

  Contains bot token, FSM state/data, and builder request data.
  """
  @type context :: %{
          required(:token) => String.t(),
          required(:state) => atom() | nil,
          required(:data) => term(),
          optional(:message_thread_id) => integer(),
          optional(:payload) => map(),
          optional(:chat_id) => integer(),
          optional(:method) => String.t(),
          optional(:format) => :json | :multipart
        }

  @typedoc """
  Return value from handlers.

  Builder pipelines return `TelegramEx.Effect` values. The server converts them
  to ordinary handler results before applying FSM transitions or logging errors.
  """
  @type handler_result ::
          :ok
          | :pass
          | TelegramEx.Effect.t()
          | {:transition, new_state :: atom()}
          | {:transition, new_state :: atom(), data :: term()}
          | {:stay, data :: term()}
          | {:error, reason :: term()}

  @doc """
  Callback invoked when a message is received.

  Return a `t:handler_result/0`. See [Getting Started](getting-started.md)
  for handler examples.
  """
  @callback handle_message(message :: Types.Message.t(), context :: context()) ::
              handler_result()

  @doc """
  Callback invoked when a callback query (inline button press) is received.

  Return a `t:handler_result/0`. See
  [Messages and Media](messages-and-media.md) for callback examples.
  """
  @callback handle_callback(callback :: Types.CallbackQuery.t(), context :: context()) ::
              handler_result()

  defmacro __using__(opts) do
    quote do
      @behaviour TelegramEx

      import TelegramEx
      import TelegramEx.FSM, only: [defstate: 2]
      import TelegramEx.Command, only: [defcommand: 3]
      alias TelegramEx.{API, Config, FSM}
      alias TelegramEx.Builder.{Contact, Document, Location, Message, Photo, Poll, Sticker, Video}

      @bot_name Keyword.fetch!(unquote(opts), :name)
      @routers Keyword.get(unquote(opts), :routers, [])
      Module.register_attribute(__MODULE__, :commands, accumulate: true)

      def child_spec(_) do
        %{
          id: __MODULE__,
          start: {TelegramEx.Server, :start_link, [__MODULE__, @bot_name, @routers]},
          type: :worker
        }
      end

      @before_compile TelegramEx
    end
  end

  defmacro __before_compile__(env) do
    commands =
      env.module
      |> Module.get_attribute(:commands)
      |> Enum.reverse()

    quote do
      def __commands__, do: unquote(Macro.escape(commands))
      def __routers__, do: @routers
      def handle_message(_message, _ctx), do: :ok
      def handle_callback(_callback, _ctx), do: :ok
    end
  end
end
