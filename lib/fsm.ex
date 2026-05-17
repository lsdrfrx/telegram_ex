defmodule TelegramEx.FSM do
  @moduledoc """
  Per-user Finite State Machine backed by Pockets (ETS).

  This module provides per-user state management for conversational bots.
  Each user (identified by chat ID) can have their own state and associated data,
  allowing you to build multi-step workflows, wizards, and stateful interactions.

  The FSM stores tuples of `{state, data}` keyed by chat ID in an ETS table
  managed by the Pockets library.

  ## State Management

  - **State**: An atom representing the current conversation state (e.g., `:waiting_name`, `:confirming`)
  - **Data**: Any Elixir term to store context (e.g., `%{step: 1, answers: []}`)

  ## Usage

      # Get current state and data
      {state, data} = FSM.get_state(:my_bot, chat_id)

      # Set state only (keeps existing data)
      FSM.set_state(:my_bot, chat_id, :waiting_name)

      # Set state and data
      FSM.set_state(:my_bot, chat_id, :waiting_name, %{step: 1})

      # Reset state (removes entry)
      FSM.reset_state(:my_bot, chat_id)

  ## Using with defstate

  The `defstate/2` macro allows you to define handlers that only match
  when the user is in a specific state:

      defstate :waiting_name do
        def handle_message(%{text: text, chat: chat}, ctx) do
          # This only runs when user is in :waiting_name state
          {:transition, :waiting_age, Map.put(ctx.data, :name, text)}
        end
      end

  """

  @type chat_id :: TelegramEx.Types.chat_id()

  @doc """
  Initializes the FSM storage for a bot.

  This is called automatically by `TelegramEx.Server` when the bot starts.
  You typically don't need to call this manually.

  ## Parameters

  - `name` - The bot name (atom)

  ## Returns

  - `:ok` - FSM initialized successfully
  - `{:error, reason}` - Initialization failed
  """
  @spec init(atom()) :: :ok | {:error, term()}
  def init(name) do
    case Pockets.new(name) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Resets the FSM state for a user, removing their stored state and data.

  ## Parameters

  - `name` - The bot name (atom)
  - `id` - The chat ID

  ## Returns

  - `:ok` - State reset successfully
  - `{:error, reason}` - Failed to reset state

  ## Examples

      FSM.reset_state(:my_bot, 123456)
      # User's state is now cleared
  """
  @spec reset_state(atom(), chat_id()) :: atom() | {:error, term()}
  def reset_state(name, id) do
    Pockets.delete(name, id)
  end

  @doc """
  Retrieves the current FSM state and data for a user.

  ## Parameters

  - `name` - The bot name (atom)
  - `id` - The chat ID

  ## Returns

  A tuple `{state, data}` where:
  - `state` - Current state atom (or `nil` if no state set)
  - `data` - Associated data (or `nil` if no data set)

  ## Examples

      {state, data} = FSM.get_state(:my_bot, 123456)
      # => {:waiting_name, %{step: 1}}

      {state, data} = FSM.get_state(:my_bot, 999999)
      # => {nil, nil}  # User has no state
  """
  @spec get_state(atom(), chat_id()) :: {term(), term()}
  def get_state(name, id) do
    Pockets.get(name, id, {nil, nil})
  end

  @doc """
  Sets the FSM state for a user, keeping existing data.

  ## Parameters

  - `name` - The bot name (atom)
  - `id` - The chat ID
  - `state` - New state atom

  ## Returns

  - `:ok` - State set successfully
  - `{:error, reason}` - Failed to set state

  ## Examples

      FSM.set_state(:my_bot, 123456, :waiting_age)
      # State changed to :waiting_age, data preserved
  """
  @spec set_state(atom(), chat_id(), atom()) :: atom() | {:error, term()}
  def set_state(name, id, state) do
    {_, data} = get_state(name, id)
    Pockets.put(name, id, {state, data})
  end

  @doc """
  Sets the FSM state and data for a user.

  ## Parameters

  - `name` - The bot name (atom)
  - `id` - The chat ID
  - `state` - New state atom
  - `data` - New data to store

  ## Returns

  - `:ok` - State and data set successfully
  - `{:error, reason}` - Failed to set state

  ## Examples

      FSM.set_state(:my_bot, 123456, :waiting_age, %{name: "John", step: 2})
      # State and data both updated
  """
  @spec set_state(atom(), chat_id(), atom(), term()) :: atom() | {:error, term()}
  def set_state(name, id, state, data) do
    Pockets.put(name, id, {state, data})
  end

  @doc """
  Defines handlers that only execute when the user is in a specific FSM state.

  This macro automatically injects state pattern matching into handler functions,
  so they only run when the user's FSM state matches the specified state.

  ## Parameters

  - `state` - The state atom to match
  - `do` - Block containing handler function definitions

  ## Examples

      defstate :waiting_name do
        def handle_message(%{text: text, chat: chat}, ctx) do
          # Only runs when user is in :waiting_name state
          ctx
          |> Message.text("Got your name: \#{text}")
          |> Message.send(chat["id"])

          {:transition, :waiting_age, Map.put(ctx.data, :name, text)}
        end
      end

      defstate :waiting_age do
        def handle_message(%{text: age, chat: chat}, ctx) do
          # Only runs when user is in :waiting_age state
          name = ctx.data.name

          ctx
          |> Message.text("Hello \#{name}, you are \#{age} years old")
          |> Message.send(chat["id"])

          FSM.reset_state(:my_bot, chat["id"])
        end
      end

  ## Note

  The `ctx` parameter in handlers defined within `defstate` will have
  `ctx.state` automatically matched to the specified state atom.
  """
  defmacro defstate(state, do: block) do
    Macro.prewalk(block, fn
      {:def, def_meta, [func_header | rest]} ->
        {name, meta, args} = func_header

        new_args =
          case args do
            [msg_arg, {:=, eq_meta, [{:%{}, map_meta, pairs}, binding]}] ->
              [msg_arg, {:=, eq_meta, [{:%{}, map_meta, [{:state, state} | pairs]}, binding]}]

            [msg_arg, {var_name, var_meta, var_ctx}] ->
              binding = {var_name, var_meta, var_ctx}
              [msg_arg, {:=, [], [{:%{}, [], [{:state, state}]}, binding]}]

            _ ->
              args
          end

        {:def, def_meta, [{name, meta, new_args} | rest]}

      other ->
        other
    end)
  end
end
