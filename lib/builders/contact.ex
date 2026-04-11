defmodule TelegramEx.Builder.Contact do
  @moduledoc """
  Builder for contact payloads.

      Contact.contact("John", "+123456789")
      |> Contact.send(chat_id)

      Contact.contact("John", "Doe", "+123456789")
      |> Contact.send(chat_id)
  """

  alias TelegramEx.API

  def contact(name, phone) do
    %{phone_number: phone, first_name: name}
  end

  def contact(first_name, last_name, phone) do
    %{
      phone_number: phone,
      first_name: first_name,
      last_name: last_name
    }
  end

   def silent(contact) do
    Map.put(contact, :disable_notification, true)
  end

  def send(contact, id) do
    contact
    |> Map.put(:chat_id, id)
    |> then(&API.send_contact(Process.get(:token), &1))
  end
end
