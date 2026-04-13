defmodule Example.Routers.Survey do
  @moduledoc """
  Survey router — demonstrates multi-step FSM with data accumulation.
  States: :survey_name → :survey_age → :survey_confirm
  """
  use TelegramEx.Router

  # ── Step 1: Collect name ───────────────────────────────────────────
  defstate :survey_name do
    def handle_message(%{text: "/cancel", chat: chat}, ctx) do
      ctx
      |> Message.text("Survey cancelled.")
      |> Message.send(chat["id"])

      FSM.reset_state(:example_bot, chat["id"])
    end

    def handle_message(%{text: name, chat: chat}, ctx) do
      ctx
      |> Message.text("Nice to meet you, *#{name}*!\n\nHow old are you?", "Markdown")
      |> Message.send(chat["id"])

      {:transition, :survey_age, Map.put(ctx.data, :name, name)}
    end
  end

  # ── Step 2: Collect age ────────────────────────────────────────────
  defstate :survey_age do
    def handle_message(%{text: "/cancel", chat: chat}, ctx) do
      ctx
      |> Message.text("Survey cancelled.")
      |> Message.send(chat["id"])

      FSM.reset_state(:example_bot, chat["id"])
    end

    def handle_message(%{text: age_text, chat: chat}, ctx) do
      case Integer.parse(age_text) do
        {age, ""} when age > 0 and age < 150 ->
          data = Map.put(ctx.data, :age, age)

          keyboard = [
            [
              %{text: "✅ Confirm", callback_data: "survey_confirm"},
              %{text: "🔄 Restart", callback_data: "survey_restart"}
            ]
          ]

          summary = """
          📋 *Survey Summary*

          Name: *#{data.name}*
          Age: *#{data.age}*

          Is this correct?
          """

          ctx
          |> Message.text(summary, "Markdown")
          |> Message.inline_keyboard(keyboard)
          |> Message.send(chat["id"])

          {:transition, :survey_confirm, data}

        _ ->
          ctx
          |> Message.text("Please enter a valid age (number between 1 and 149).")
          |> Message.send(chat["id"])

          :ok
      end
    end
  end

  # ── Step 3: Confirm ────────────────────────────────────────────────
  defstate :survey_confirm do
    def handle_callback(%{data: "survey_confirm", message: %{chat: chat}} = cb, ctx) do
      ctx
      |> Message.text("🎉 Survey completed!\n\nThank you, *#{ctx.data.name}* (age #{ctx.data.age})!", "Markdown")
      |> Message.answer_callback_query(cb)
      |> Message.send(chat["id"])

      FSM.reset_state(:example_bot, chat["id"])
    end

    def handle_callback(%{data: "survey_restart", message: %{chat: chat}} = cb, ctx) do
      ctx
      |> Message.text("🔄 Let's start over.\n\nWhat is your name?")
      |> Message.answer_callback_query(cb)
      |> Message.send(chat["id"])

      {:transition, :survey_name, %{}}
    end

    def handle_message(%{text: "/cancel", chat: chat}, ctx) do
      ctx
      |> Message.text("Survey cancelled.")
      |> Message.send(chat["id"])

      FSM.reset_state(:example_bot, chat["id"])
    end
  end
end
