defmodule Example.Bot do
  use TelegramEx, name: :example_bot

  def handle_message(%{text: "/start", chat: chat}) do
    Message.text("Started")
    |> Message.send(chat["id"])

    {:transition, :started, %{foo: "bar"}}
  end

  defstate :started do
    def handle_message(%{text: "/start", chat: chat}, _data) do
      Message.text("Already started")
      |> Message.send(chat["id"])

      {:stay, %{foo: "baz"}}
    end

    def handle_message(%{text: text, chat: chat}, _data) do
      Message.text("You said: #{text}")
      |> Message.send(chat["id"])
    end
  end
end
