defmodule TelegramEx.FSM do
  @table :telegram_ex_table
  def init() do
    :ets.new(@table, [:set, :public, :named_table])
  end

  def get_current_state(id) do
    case :ets.lookup(@table, id) do
      [{_id, {state, _data}} | _] -> state
      [] -> nil
    end
  end

  def transition_to(id, state) do
    set_current_state(id, state)
  end

  def set_data(id, data) do
    case :ets.lookup(@table, id) do
      [{_id, {state, _}} | _] ->
        :ets.insert(@table, {id, {state, data}})

      [] ->
        :ets.insert(@table, {id, {nil, data}})
    end
  end

  def get_data(id) do
    case :ets.lookup(@table, id) do
      [{_id, {_state, data}} | _] -> data
      [] -> %{}
    end
  end

  def set_current_state(id, state) do
    existing_data = get_data(id)
    :ets.insert(@table, {id, {state, existing_data}})
  end

  def set_current_state(id, state, data) do
    :ets.insert(@table, {id, {state, data}})
  end

  defmacro defstate(state, do: block) do
    Macro.prewalk(block, fn
      {:def, def_meta, [func_header | rest]} ->
        {name, meta, args} = func_header

        new_args =
          case args do
            [msg_arg] ->
              [msg_arg, state, {:_data, [], nil}]

            [msg_arg, data_arg] ->
              [msg_arg, state, data_arg]

            _ ->
              args
          end

        {:def, def_meta, [{name, meta, new_args} | rest]}

      other ->
        other
    end)
  end
end
