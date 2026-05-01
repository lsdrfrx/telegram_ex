defmodule TelegramEx do
  @moduledoc """
  Defines a behaviour for Telegram bots and provides the main `use` macro.

  When you `use TelegramEx` in your module, the macro injects:

  1. **Behaviour implementation** - Sets `@behaviour TelegramEx` requiring you to implement
     `handle_message/2` and `handle_callback/2` callbacks.

  2. **Imports and aliases** - Automatically imports `TelegramEx` and `TelegramEx.FSM.defstate/2`,
     and aliases commonly used modules (`API`, `Config`, `FSM`, and all builder modules).

  3. **Child spec** - Generates a `child_spec/1` function that returns a supervisor child
     specification. This allows your bot module to be added directly to a supervision tree.
     The child spec starts `TelegramEx.Server` which handles polling and message dispatch.

  4. **Default implementations** - Via `@before_compile`, injects default implementations
     of `handle_message/2` and `handle_callback/2` that return `:ok`. These are used as
     fallbacks if you don't define your own catch-all clauses.

  ## Macro Options

  - `:name` (required) - Atom identifier for the bot, stored in `@bot_name` module attribute.
    Used for configuration lookup and FSM storage.

  - `:routers` (optional) - List of router modules, stored in `@routers` module attribute.
    Routers are tried in order before the main bot module when handling updates.

  ## Example

      defmodule MyBot do
        use TelegramEx, name: :my_bot, routers: [MyApp.AdminRouter]

        def handle_message(%{text: "/start", chat: chat}, ctx) do
          ctx
          |> Message.text("Hello!")
          |> Message.send(chat["id"])
        end

        def handle_callback(%{data: data}, ctx), do: :ok
      end

  This expands to approximately:

      defmodule MyBot do
        @behaviour TelegramEx

        import TelegramEx
        import TelegramEx.FSM, only: [defstate: 2]
        alias TelegramEx.{API, Config, FSM}
        alias TelegramEx.Builder.{Contact, Document, Location, Message, Photo, Sticker, Video}

        @bot_name :my_bot
        @routers [MyApp.AdminRouter]

        def child_spec(_) do
          %{
            id: __MODULE__,
            start: {TelegramEx.Server, :start_link, [__MODULE__, @bot_name, @routers]},
            type: :worker
          }
        end

        def handle_message(%{text: "/start", chat: chat}, ctx) do
          # your implementation
        end

        def handle_callback(%{data: data}, ctx), do: :ok

        # Injected by @before_compile as fallback
        def handle_message(_message, _ctx), do: :ok
        def handle_callback(_callback, _ctx), do: :ok
      end

  The generated `child_spec/1` allows you to add the bot to your supervision tree:

      children = [MyBot]
      Supervisor.start_link(children, strategy: :one_for_one)

  When supervised, `TelegramEx.Server` starts and begins polling Telegram for updates,
  calling your `handle_message/2` and `handle_callback/2` implementations.
  """

  alias TelegramEx.Types

  @typedoc """
  Context map passed to all handlers.

  Contains bot token, FSM state/data, and builder accumulator.
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
  Return value from handlers indicating state transitions.
  """
  @type handler_result ::
          :ok
          | :pass
          | {:transition, new_state :: atom()}
          | {:transition, new_state :: atom(), data :: term()}
          | {:stay, data :: term()}
          | {:error, reason :: term()}

  @doc """
  Callback invoked when a message is received.

  ## Parameters

  - `message` - A `TelegramEx.Types.Message` struct containing the incoming message
  - `context` - Context map with bot token, FSM state, and data

  ## Returns

  A `t:handler_result/0` indicating how to handle the message.

  ## Example

      def handle_message(%{text: "/start", chat: chat}, ctx) do
        ctx
        |> Message.text("Welcome!")
        |> Message.send(chat["id"])

        {:transition, :started}
      end
  """
  @callback handle_message(message :: Types.Message.t(), context :: context()) ::
              handler_result()

  @doc """
  Callback invoked when a callback query (inline button press) is received.

  ## Parameters

  - `callback` - A `TelegramEx.Types.CallbackQuery` struct
  - `context` - Context map with bot token, FSM state, and data

  ## Returns

  A `t:handler_result/0` indicating how to handle the callback.

  ## Example

      def handle_callback(%{data: "confirm"} = callback, ctx) do
        ctx
        |> Message.text("Confirmed!")
        |> Message.answer_callback_query(callback)
        |> Message.send(callback.message.chat["id"])
      end
  """
  @callback handle_callback(callback :: Types.CallbackQuery.t(), context :: context()) ::
              handler_result()

  defmacro __using__(opts) do
    quote do
      @behaviour TelegramEx

      import TelegramEx
      import TelegramEx.FSM, only: [defstate: 2]
      alias TelegramEx.{API, Config, FSM}
      alias TelegramEx.Builder.{Contact, Document, Location, Message, Photo, Sticker, Video}

      @bot_name Keyword.fetch!(unquote(opts), :name)
      @routers Keyword.get(unquote(opts), :routers, [])

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

  defmacro __before_compile__(_env) do
    quote do
      def handle_message(_message, _ctx), do: :ok
      def handle_callback(_callback, _ctx), do: :ok
    end
  end
end
