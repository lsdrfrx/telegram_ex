defmodule TelegramEx.FSM do
  @moduledoc """
  Per-user Finite State Machine backed by Pockets (ETS).

  Stores `{state, data}` per chat and provides `defstate/2` for state-specific
  handlers. See [Finite State Machines](fsm.md) for workflow examples.
  """

  @type chat_id :: TelegramEx.Types.chat_id()

  @doc """
  Initializes the FSM storage for a bot.

  This is called automatically by `TelegramEx.Server` when the bot starts.
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
  """
  @spec reset_state(atom(), chat_id()) :: atom() | {:error, term()}
  def reset_state(name, id) do
    Pockets.delete(name, id)
  end

  @doc """
  Retrieves the current FSM state and data for a user.

  Returns `{nil, nil}` when the chat has no stored state.
  """
  @spec get_state(atom(), chat_id()) :: {term(), term()}
  def get_state(name, id) do
    Pockets.get(name, id, {nil, nil})
  end

  @doc """
  Sets the FSM state for a user, keeping existing data.
  """
  @spec set_state(atom(), chat_id(), atom()) :: atom() | {:error, term()}
  def set_state(name, id, state) do
    {_, data} = get_state(name, id)
    Pockets.put(name, id, {state, data})
  end

  @doc """
  Sets the FSM state and data for a user.
  """
  @spec set_state(atom(), chat_id(), atom(), term()) :: atom() | {:error, term()}
  def set_state(name, id, state, data) do
    Pockets.put(name, id, {state, data})
  end

  @doc """
  Defines handlers that only execute when the user is in a specific FSM state.

  See [Finite State Machines](fsm.md) for a complete multi-step example.
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
