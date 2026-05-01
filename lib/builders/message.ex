defmodule TelegramEx.Builder.Message do
  @moduledoc """
  Builder for constructing and sending text messages.

  This module provides a fluent, pipeline-based API for building text messages
  with various options like keyboards, parse modes, and notifications.

  ## Pipeline Pattern

  All functions accept a context map (`ctx`) as the first argument and return
  an updated context, allowing you to chain operations:

      ctx
      |> Message.text("Hello, world!")
      |> Message.inline_keyboard([[%{text: "Click me", callback_data: "btn_1"}]])
      |> Message.send(chat_id)

  ## Examples

      # Simple text message
      def handle_message(%{chat: chat}, ctx) do
        ctx
        |> Message.text("Hello!")
        |> Message.send(chat["id"])
      end

      # Message with Markdown formatting
      ctx
      |> Message.text("*Bold* and _italic_", "Markdown")
      |> Message.send(chat_id)

      # Message with inline keyboard
      keyboard = [[
        %{text: "Yes", callback_data: "yes"},
        %{text: "No", callback_data: "no"}
      ]]

      ctx
      |> Message.text("Do you agree?")
      |> Message.inline_keyboard(keyboard)
      |> Message.send(chat_id)

      # Silent message (no notification)
      ctx
      |> Message.text("Quiet message")
      |> Message.silent()
      |> Message.send(chat_id)
  """

  alias TelegramEx.API

  @doc """
  Sets the text content of the message.

  ## Parameters

  - `ctx` - Context map
  - `text` - Message text content

  ## Returns

  Updated context map with text set.

  ## Examples

      ctx
      |> Message.text("Hello, world!")
      |> Message.send(chat_id)
  """
  @spec text(map(), String.t()) :: map()
  def text(ctx, text) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:text, text)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sets the text content and parse mode of the message.

  ## Parameters

  - `ctx` - Context map
  - `text` - Message text content
  - `parse_mode` - Parse mode ("Markdown", "MarkdownV2", or "HTML")

  ## Returns

  Updated context map with text and parse mode set.

  ## Examples

      ctx
      |> Message.text("*Bold* and _italic_", "Markdown")
      |> Message.send(chat_id)

      ctx
      |> Message.text("<b>Bold</b> and <i>italic</i>", "HTML")
      |> Message.send(chat_id)
  """
  @spec text(map(), String.t(), String.t()) :: map()
  def text(ctx, text, parse_mode) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:text, text)
    |> Map.put(:parse_mode, parse_mode)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Adds an inline keyboard to the message.

  Inline keyboards appear directly below the message and trigger callback queries.

  ## Parameters

  - `ctx` - Context map
  - `keyboard` - List of button rows, where each row is a list of button maps

  ## Button Format

  Each button is a map with:
  - `:text` - Button label (required)
  - `:callback_data` - Data sent when button is pressed
  - `:url` - URL to open when button is pressed

  ## Returns

  Updated context map with inline keyboard set.

  ## Examples

      keyboard = [[
        %{text: "Yes", callback_data: "confirm_yes"},
        %{text: "No", callback_data: "confirm_no"}
      ]]

      ctx
      |> Message.text("Do you agree?")
      |> Message.inline_keyboard(keyboard)
      |> Message.send(chat_id)
  """
  @spec inline_keyboard(map(), list(list(map()))) :: map()
  def inline_keyboard(ctx, keyboard) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:reply_markup, %{inline_keyboard: keyboard})
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Adds a reply keyboard to the message.

  Reply keyboards replace the user's keyboard with custom buttons.

  ## Parameters

  - `ctx` - Context map
  - `keyboard` - List of button rows, where each row is a list of strings
  - `opts` - Keyword list of options

  ## Options

  - `:resize_keyboard` - Request clients to resize the keyboard
  - `:one_time_keyboard` - Hide keyboard after first use

  ## Returns

  Updated context map with reply keyboard set.

  ## Examples

      keyboard = [["Option 1", "Option 2"], ["Cancel"]]

      ctx
      |> Message.text("Choose an option:")
      |> Message.reply_keyboard(keyboard, resize_keyboard: true, one_time_keyboard: true)
      |> Message.send(chat_id)
  """
  @spec reply_keyboard(map(), list(list(String.t())), keyword()) :: map()
  def reply_keyboard(ctx, keyboard, opts) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:reply_markup, Map.merge(%{keyboard: keyboard}, Map.new(opts)))
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Removes the custom keyboard.

  ## Parameters

  - `ctx` - Context map

  ## Returns

  Updated context map with keyboard removal flag set.

  ## Examples

      ctx
      |> Message.text("Keyboard removed")
      |> Message.remove_keyboard()
      |> Message.send(chat_id)
  """
  @spec remove_keyboard(map()) :: map()
  def remove_keyboard(ctx) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:reply_markup, %{remove_keyboard: true})
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Sends the message without notification sound.

  ## Parameters

  - `ctx` - Context map

  ## Returns

  Updated context map with silent flag set.

  ## Examples

      ctx
      |> Message.text("Silent message")
      |> Message.silent()
      |> Message.send(chat_id)
  """
  @spec silent(map()) :: map()
  def silent(ctx) do
    Map.get(ctx, :payload, %{})
    |> Map.put(:disable_notification, true)
    |> then(&Map.put(ctx, :payload, &1))
  end

  @doc """
  Answers a callback query from an inline keyboard button.

  This should be called when handling callback queries to acknowledge them.

  ## Parameters

  - `ctx` - Context map
  - `callback` - The callback query struct

  ## Returns

  The context map unchanged.

  ## Examples

      def handle_callback(%{data: "confirm"} = callback, ctx) do
        ctx
        |> Message.text("Confirmed!")
        |> Message.answer_callback_query(callback)
        |> Message.send(callback.message.chat["id"])
      end
  """
  @spec answer_callback_query(map(), TelegramEx.Types.CallbackQuery.t()) :: map()
  def answer_callback_query(ctx, callback) do
    API.answer_callback_query(Process.get(:token), callback)
    ctx
  end

  @doc """
  Sends the message to the specified chat.

  This is the final step in the builder pipeline that actually sends the message.

  ## Parameters

  - `ctx` - Context map with accumulated message data
  - `id` - Chat ID to send the message to

  ## Returns

  - `:ok` - Message sent successfully
  - `{:error, reason}` - Failed to send message

  ## Examples

      ctx
      |> Message.text("Hello!")
      |> Message.send(chat_id)
  """
  @spec send(map(), integer()) :: :ok | {:error, term()}
  def send(ctx, id) do
    ctx
    |> Map.put(:chat_id, id)
    |> Map.put(:method, "sendMessage")
    |> Map.put(:format, :json)
    |> API.request()
  end
end
