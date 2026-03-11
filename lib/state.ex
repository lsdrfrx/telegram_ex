defmodule TelegramEx.State do
  @table :telegram_ex_table
  def init() do
    :ets.new(@table, [:set, :public, :named_table])
  end

  def get_current_state(id) do
    case :ets.lookup(@table, id) do
      [{_id, state}| _] -> state
      [] -> nil
    end
  end

  def set_current_state(id, state) do
    :ets.insert(@table, {id, state})
  end
end
