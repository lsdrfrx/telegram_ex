defmodule TelegramEx.Server do
  use GenServer
  require Logger
  alias TelegramEx.{API, Types, FSM}

  def start_link(bot_module, token),
    do: GenServer.start_link(__MODULE__, {bot_module, token}, name: bot_module)

  def init({bot_module, token}) do
    FSM.init()

    state = %{
      bot_module: bot_module,
      token: token,
      offset: 0
    }

    {:ok, state, {:continue, :start_polling}}
  end

  def handle_continue(:start_polling, state) do
    Task.start_link(fn -> poll_updates(state) end)
    {:noreply, state}
  end

  defp poll_updates(
         %{bot_module: bot_module, token: token, offset: offset} =
           state
       ) do
    case API.get_updates(token, offset) do
      {:ok, updates} ->
        Enum.each(updates, &process_update(&1, bot_module))

        new_offset =
          case updates do
            [] -> state.offset
            updates -> List.last(updates)["update_id"] + 1
          end

        poll_updates(%{state | offset: new_offset})

      {:error, reason} ->
        IO.inspect(reason)
        poll_updates(state)
    end
  end

  defp process_update(update, bot_module) do
    cond do
      update["message"] ->
        update["message"]
        |> parse_message()
        |> run_handler(bot_module, :handle_message)

      update["callback_query"] ->
        update["callback_query"]
        |> parse_callback_query()
        |> run_handler(bot_module, :handle_callback)
    end
  end

  defp run_handler(message, bot_module, handler) do
    current_state = FSM.get_current_state(message.chat["id"])

    if function_exported?(bot_module, handler, 3) and current_state do
      data = FSM.get_data(message.chat["id"])
      apply(bot_module, handler, [message, current_state, data])
    else
      apply(bot_module, handler, [message])
    end
    |> case do
      {:transition, new_state, data} ->
        FSM.transition_to(message.chat["id"], new_state)
        FSM.set_data(message.chat["id"], data)

      {:transition, new_state} ->
        FSM.transition_to(message.chat["id"], new_state)

      {:stay, data} ->
        FSM.set_data(message.chat["id"], data)

      :ok -> :ok

      {:error, reason} ->
        Logger.error("Handler error: #{inspect(reason)}")

      error ->
        Logger.error("Unknown handler response: #{inspect(error)}")
    end
  end

  defp parse_message(message), do: Types.Message.from_map(message)
  defp parse_callback_query(callback_query), do: Types.CallbackQuery.from_map(callback_query)
end
