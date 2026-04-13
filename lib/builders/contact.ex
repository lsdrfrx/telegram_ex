defmodule TelegramEx.Builder.Contact do
  @moduledoc """
  Builder for contact payloads.

      Contact.contact(ctx, "John", "+123456789")
      |> Contact.send(chat_id)

      Contact.contact(ctx, "John", "Doe", "+123456789")
      |> Contact.send(chat_id)
  """

  alias TelegramEx.API

  def contact(ctx, name, phone) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:phone_number, phone)
    |> Map.put(:first_name, name)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def contact(ctx, first_name, last_name, phone) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:phone_number, phone)
    |> Map.put(:first_name, first_name)
    |> Map.put(:last_name, last_name)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def silent(ctx) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:disable_notification, true)
    |> then(&Map.put(ctx, :payload, &1))
  end

  def send(ctx, id) do
    ctx
    |> Map.put(:chat_id, id)
    |> Map.put(:method, "sendContact")
    |> Map.put(:format, :json)
    |> API.request()
  end
end
