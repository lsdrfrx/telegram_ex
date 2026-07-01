defmodule TelegramEx.Builder.Contact do
  @moduledoc """
  Builder for contact payloads.

  Builds `sendContact` payloads. See
  [Messages and Media](messages-and-media.md).
  """

  alias TelegramEx.API
  alias TelegramEx.Builder
  alias TelegramEx.Effect

  @type input :: map() | Effect.t()

  @doc """
  Sets contact information with first name and phone number.
  """
  @spec contact(input(), String.t(), String.t()) :: Effect.t()
  def contact(input, name, phone) do
    input
    |> Builder.put_payload(:phone_number, phone)
    |> Builder.put_payload(:first_name, name)
  end

  @doc """
  Sets contact information with first name, last name, and phone number.
  """
  @spec contact(input(), String.t(), String.t(), String.t()) :: Effect.t()
  def contact(input, first_name, last_name, phone) do
    input
    |> Builder.put_payload(:phone_number, phone)
    |> Builder.put_payload(:first_name, first_name)
    |> Builder.put_payload(:last_name, last_name)
  end

  @doc """
  Sends the contact without notification sound.
  """
  @spec silent(input()) :: Effect.t()
  def silent(input) do
    Builder.put_payload(input, :disable_notification, true)
  end

  @doc """
  Sends the contact to the specified chat.
  """
  @spec send(input(), integer()) :: Effect.t()
  def send(input, id) do
    input
    |> Effect.wrap()
    |> Effect.then(fn ctx ->
      new_ctx =
        ctx
        |> Map.put(:chat_id, id)
        |> Map.put(:method, "sendContact")
        |> Map.put(:format, :json)

      case API.request(new_ctx) do
        :ok -> {:ok, new_ctx}
        {:error, reason} -> {:error, reason}
      end
    end)
  end
end
