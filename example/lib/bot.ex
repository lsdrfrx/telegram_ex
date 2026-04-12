defmodule Example.Bot do
  use TelegramEx,
    name: :example_bot,
    routers: [Example.Routers.Admin]

  def handle_message(%{text: "/start", chat: chat}) do
    Message.text("Started")
    |> Message.send(chat["id"])
  end

  def handle_message(%{text: "/admin", chat: chat}) do
    Message.text("Entering admin mode")
    |> Message.send(chat["id"])

    {:transition, :admin}
  end
end
