defmodule Example.Routers.Admin do
  use TelegramEx.Router

  defstate :admin do
    def handle_message(%{text: "/exit", chat: chat}, _data) do
      Message.text("Exiting admin mode")
      |> Message.send(chat["id"])

      FSM.reset_state(:example_bot, chat["id"])
    end

    def handle_message(%{text: text, chat: chat}, _data) do
      Message.text("Admin command received: #{text}")
      |> Message.send(chat["id"])
    end
  end
end
