defmodule TelegramEx.Builder.Contact do
  @moduledoc """
  Builder for contact payloads.

  This module provides a fluent API for sending contact information.

  ## Examples

      # Send contact with first name only
      ctx
      |> Contact.contact("John", "+123456789")
      |> Contact.send(chat_id)

      # Send contact with first and last name
      ctx
      |> Contact.contact("John", "Doe", "+123456789")
      |> Contact.send(chat_id)

      # Send contact silently
      ctx
      |> Contact.contact("Jane", "+987654321")
      |> Contact.silent()
      |> Contact.send(chat_id)
  """

  alias TelegramEx.API

  @doc """
  Sets contact information with first name and phone number.

  ## Parameters

  - `ctx` - Context map
  - `name` - Contact's first name
  - `phone` - Contact's phone number

  ## Returns

  Updated context map with contact data set.

  ## Examples

      ctx
      |> Contact.contact("John", "+1234567890")
      |> Contact.send(chat_id)
  """
  @spec contact(map(), String.t(), String.t()) :: map()
  def contact(ctx, name, phone) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:phone_number, phone)
    |> Map.put(:first_name, name)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sets contact information with first name, last name, and phone number.

  ## Parameters

  - `ctx` - Context map
  - `first_name` - Contact's first name
  - `last_name` - Contact's last name
  - `phone` - Contact's phone number

  ## Returns

  Updated context map with contact data set.

  ## Examples

      ctx
      |> Contact.contact("John", "Doe", "+1234567890")
      |> Contact.send(chat_id)
  """
  @spec contact(map(), String.t(), String.t(), String.t()) :: map()
  def contact(ctx, first_name, last_name, phone) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:phone_number, phone)
    |> Map.put(:first_name, first_name)
    |> Map.put(:last_name, last_name)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sends the contact without notification sound.

  ## Parameters

  - `ctx` - Context map

  ## Returns

  Updated context map with silent flag set.
  """
  @spec silent(map()) :: map()
  def silent(ctx) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:disable_notification, true)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sends the contact to the specified chat.

  ## Parameters

  - `ctx` - Context map with accumulated contact data
  - `id` - Chat ID to send the contact to

  ## Returns

  - `:ok` - Contact sent successfully
  - `{:error, reason}` - Failed to send contact
  """
  @spec send(map(), integer()) :: :ok | {:error, term()}
  def send(ctx, id) do
    ctx
    |> Map.put(:chat_id, id)
    |> Map.put(:method, "sendContact")
    |> Map.put(:format, :json)
    |> API.request()
  end
end
