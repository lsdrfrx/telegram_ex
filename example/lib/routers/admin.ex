defmodule Example.Routers.Admin do
  @moduledoc """
  Admin router — demonstrates Router + defstate.
  Active when FSM state is :admin.
  """
  use TelegramEx.Router

  defstate :admin do
    def handle_message(%{text: "/exit", chat: chat}, ctx) do
      ctx
      |> Message.text("Exiting admin mode.")
      |> Message.remove_keyboard()
      |> Message.send(chat["id"])

      FSM.reset_state(:example_bot, chat["id"])
      :ok
    end

    def handle_message(%{text: text, chat: chat}, ctx) do
      ctx
      |> Message.text("*Admin echo:* `#{text}`", "Markdown")
      |> Message.send(chat["id"])
    end
  end
end
