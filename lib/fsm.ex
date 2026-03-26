defmodule TelegramEx.FSM do
  @moduledoc """
  Per-user FSM backed by Pockets (ETS). Stores `{state, data}` keyed by chat ID.

      FSM.set_state(bot_name, chat_id, :waiting_name)
      FSM.set_state(bot_name, chat_id, :waiting_name, %{step: 1})

      FSM.get_state(bot_name, chat_id)  # => {:waiting_name, %{step: 1}}
  """

  def init(name) do
    case Pockets.new(name) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def reset_state(name, id) do
    Pockets.delete(name, id)
  end

  def get_state(name, id) do
    Pockets.get(name, id, {nil, nil})
  end

  def set_state(name, id, state) do
    {_, data} = get_state(name, id)
    Pockets.put(name, id, {state, data})
  end

  def set_state(name, id, state, data) do
    Pockets.put(name, id, {state, data})
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
