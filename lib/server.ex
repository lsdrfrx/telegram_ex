defmodule TelegramEx.Server do
  use GenServer
  require Logger
  alias TelegramEx.{API, Types, FSM, Config}

  def start_link(bot_module, bot_name),
    do: GenServer.start_link(__MODULE__, {bot_module, bot_name}, name: bot_name)

  def init({bot_module, bot_name}) do
    case FSM.init(bot_name) do
      :ok -> :ok
      {:error, reason} -> Logger.error(reason)
    end

    state = %{
      bot_module: bot_module,
      bot_name: bot_name,
      token: Config.token(bot_name),
      offset: 0
    }

    {:ok, state, {:continue, :start_polling}}
  end

  def handle_continue(:start_polling, state) do
    Task.start_link(fn -> poll_updates(state) end)
    {:noreply, state}
  end

  defp poll_updates(%{token: token, offset: offset} = state) do
    Process.put(:token, token)

    case API.get_updates(token, offset) do
      {:ok, updates} ->
        Enum.each(updates, &process_update(&1, state))

        new_offset =
          case updates do
            [] -> offset
            updates -> List.last(updates)["update_id"] + 1
          end

        poll_updates(%{state | offset: new_offset})

      {:error, reason} ->
        IO.inspect(reason)
        poll_updates(state)
    end
  end

  defp process_update(update, %{bot_module: bot_module, bot_name: bot_name}) do
    cond do
      update["message"] ->
        update["message"]
        |> parse_message()
        |> run_handler(bot_module, bot_name, :handle_message)

      update["callback_query"] ->
        update["callback_query"]
        |> parse_callback_query()
        |> run_handler(bot_module, bot_name, :handle_callback)
    end
  end

  defp run_handler(message, bot_module, bot_name, handler) do
    {state, data} = FSM.get_state(bot_name, message.chat["id"])

    if function_exported?(bot_module, handler, 3) and state do
      apply(bot_module, handler, [message, state, data])
    else
      apply(bot_module, handler, [message])
    end
    |> case do
      {:transition, new_state, data} ->
        FSM.set_state(bot_name, message.chat["id"], new_state, data)

      {:transition, new_state} ->
        FSM.set_state(bot_name, message.chat["id"], new_state)

      {:stay, data} ->
        FSM.set_state(message.chat["id"], state, data)

      :ok ->
        :ok

      {:error, reason} ->
        Logger.error("Handler error: #{inspect(reason)}")

      error ->
        Logger.error("Unknown handler response: #{inspect(error)}")
    end
  end

  defp parse_message(message), do: Types.Message.from_map(message)
  defp parse_callback_query(callback_query), do: Types.CallbackQuery.from_map(callback_query)
end
