defmodule TelegramEx.Server do
  @moduledoc """
  GenServer that long-polls Telegram for updates and dispatches them to the bot module.
  Started automatically via `child_spec/1` injected by `use TelegramEx`.
  """

  use GenServer
  require Logger
  alias TelegramEx.{API, Config, FSM, Types}

  def start_link(bot_module, bot_name),
    do: GenServer.start_link(__MODULE__, {bot_module, bot_name}, name: bot_name)

  def init({bot_module, bot_name}) do
    case FSM.init(bot_name) do
      :ok ->
        state = %{
          bot_module: bot_module,
          bot_name: bot_name,
          token: Config.token(bot_name),
          offset: 0
        }

        {:ok, state, {:continue, :start_polling}}

      {:error, reason} ->
        Logger.error("FSM initialization failed: #{reason}")
        {:stop, reason}
    end
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
        Logger.error("Error while getting update: #{reason}")
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

      true ->
        :ok
    end
  end

  defp run_handler(message, bot_module, bot_name, handler) do
    chat_id = get_chat_id(message)
    {state, data} = FSM.get_state(bot_name, chat_id)

    if function_exported?(bot_module, handler, 3) and state do
      apply(bot_module, handler, [message, state, data])
    else
      apply(bot_module, handler, [message])
    end
    |> case do
      {:transition, new_state, data} ->
        FSM.set_state(bot_name, chat_id, new_state, data)

      {:transition, new_state} ->
        FSM.set_state(bot_name, chat_id, new_state)

      {:stay, data} ->
        FSM.set_state(bot_name, chat_id, state, data)

      :ok ->
        :ok

      {:error, reason} ->
        Logger.error("Handler error: #{inspect(reason)}")

      error ->
        Logger.error("Unknown handler response: #{inspect(error)}")
    end
  end

  defp get_chat_id(%Types.CallbackQuery{message: %{chat: chat}}), do: chat["id"]
  defp get_chat_id(%Types.Message{chat: chat}), do: chat["id"]

  defp parse_message(message), do: Types.Message.from_map(message)
  defp parse_callback_query(callback_query), do: Types.CallbackQuery.from_map(callback_query)
end
