defmodule TelegramEx.FSM do
  @moduledoc """
  Per-user FSM backed by Pockets (ETS). Stores `{state, data}` keyed by chat ID.

      FSM.set_state(bot_name, chat_id, :waiting_name)
      FSM.set_state(bot_name, chat_id, :waiting_name, %{step: 1})

      FSM.get_state(bot_name, chat_id)  # => {:waiting_name, %{step: 1}}
  """

  @type chat_id :: TelegramEx.Types.chat_id()

  @spec init(atom()) :: :ok | {:error, term()}
  def init(name) do
    case Pockets.new(name) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @spec reset_state(atom(), chat_id()) :: atom() | {:error, term()}
  def reset_state(name, id) do
    Pockets.delete(name, id)
  end

  @spec get_state(atom(), chat_id()) :: {term(), term()}
  def get_state(name, id) do
    Pockets.get(name, id, {nil, nil})
  end

  @spec set_state(atom(), chat_id(), atom()) :: atom() | {:error, term()}
  def set_state(name, id, state) do
    {_, data} = get_state(name, id)
    Pockets.put(name, id, {state, data})
  end

  @spec set_state(atom(), chat_id(), atom(), term()) :: atom() | {:error, term()}
  def set_state(name, id, state, data) do
    Pockets.put(name, id, {state, data})
  end

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
