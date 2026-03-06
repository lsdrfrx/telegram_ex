defmodule TelegramEx.Bot.Server do
  use GenServer

  alias TelegramEx.API
  alias TelegramEx.Types

  def start_link(bot_module, token),
    do: GenServer.start_link(__MODULE__, {bot_module, token}, name: bot_module)

  def init({bot_module, token}) do
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

  defp poll_updates(%{bot_module: bot_module, token: token, offset: offset} = state) do
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
        |> bot_module.handle_message()

      update["callback_query"] ->
        update["callback_query"]
        |> parse_callback_query()
        |> bot_module.handle_callback()

      update["inline_query"] ->
        update["inline_query"]
        |> parse_inline_query()
        |> bot_module.handle_inline()
    end
  end

  defp parse_message(message), do: Types.Message.from_map(message)
  defp parse_callback_query(callback_query), do: callback_query
  defp parse_inline_query(inline_query), do: inline_query
end
