defmodule Example.Bot do
  use TelegramEx,
    name: :example_bot,
    routers: [Example.Routers.Admin, Example.Routers.Survey]

  # ── /start ─────────────────────────────────────────────────────────
  # Reply keyboard with all available commands
  def handle_message(%{text: "/start", chat: chat}, ctx) do
    keyboard = [
      ["/help", "/text", "/markdown"],
      ["/html", "/keyboard", "/reply_kb"],
      ["/photo", "/document", "/sticker"],
      ["/video", "/location", "/contact"],
      ["/silent", "/admin", "/survey"]
    ]

    ctx
    |> Message.text(
      "Welcome to *TelegramEx Demo Bot*!\n\nUse the keyboard below to explore all features.",
      "Markdown"
    )
    |> Message.reply_keyboard(keyboard, resize_keyboard: true)
    |> Message.send(chat["id"])
  end

  # ── /help ──────────────────────────────────────────────────────────
  # HTML parse mode example
  def handle_message(%{text: "/help", chat: chat}, ctx) do
    help = """
    <b>Available Commands</b>

    <b>Messages</b>
    /text — plain text message
    /markdown — Markdown formatted message
    /html — HTML formatted message
    /silent — message without notification

    <b>Keyboards</b>
    /keyboard — inline keyboard with callbacks
    /reply_kb — reply keyboard
    /remove_kb — remove reply keyboard

    <b>Media</b>
    /photo — send a photo (URL)
    /document — send a document (file)
    /sticker — send a sticker (file)
    /video — send a video (file)

    <b>Other</b>
    /location — send a location
    /contact — send a contact

    <b>FSM & Routers</b>
    /admin — enter admin mode (Router + FSM)
    /survey — start a multi-step survey (FSM with data)
    """

    ctx
    |> Message.text(help, "HTML")
    |> Message.send(chat["id"])
  end

  # ── /text ──────────────────────────────────────────────────────────
  def handle_message(%{text: "/text", chat: chat}, ctx) do
    ctx
    |> Message.text("This is a plain text message without any formatting.")
    |> Message.send(chat["id"])
  end

  # ── /markdown ──────────────────────────────────────────────────────
  def handle_message(%{text: "/markdown", chat: chat}, ctx) do
    md = """
    *Bold text*
    _Italic text_
    `Inline code`
    ```
    Code block
    ```
    [TelegramEx on GitHub](https://github.com/lsdrfrx/telegram_ex)
    """

    ctx
    |> Message.text(md, "Markdown")
    |> Message.send(chat["id"])
  end

  # ── /html ──────────────────────────────────────────────────────────
  def handle_message(%{text: "/html", chat: chat}, ctx) do
    html = """
    <b>Bold</b>, <i>Italic</i>, <code>code</code>
    <pre>Pre-formatted block</pre>
    <a href="https://github.com/lsdrfrx/telegram_ex">TelegramEx on GitHub</a>
    """

    ctx
    |> Message.text(html, "HTML")
    |> Message.send(chat["id"])
  end

  # ── /keyboard ──────────────────────────────────────────────────────
  # Inline keyboard with callback data
  def handle_message(%{text: "/keyboard", chat: chat}, ctx) do
    keyboard = [
      [
        %{text: "👍 Like", callback_data: "vote_like"},
        %{text: "👎 Dislike", callback_data: "vote_dislike"}
      ],
      [
        %{text: "ℹ️ Info", callback_data: "info"},
        %{text: "❌ Cancel", callback_data: "cancel"}
      ]
    ]

    ctx
    |> Message.text("Inline keyboard demo. Press a button:")
    |> Message.inline_keyboard(keyboard)
    |> Message.send(chat["id"])
  end

  # ── /reply_kb ──────────────────────────────────────────────────────
  # Reply keyboard with options
  def handle_message(%{text: "/reply_kb", chat: chat}, ctx) do
    keyboard = [
      ["Option A", "Option B"],
      ["Option C"],
      ["/remove_kb"]
    ]

    ctx
    |> Message.text("Reply keyboard demo. Choose an option or remove it:")
    |> Message.reply_keyboard(keyboard, resize_keyboard: true, one_time_keyboard: true)
    |> Message.send(chat["id"])
  end

  # ── /remove_kb ─────────────────────────────────────────────────────
  def handle_message(%{text: "/remove_kb", chat: chat}, ctx) do
    ctx
    |> Message.text("Reply keyboard removed.")
    |> Message.remove_keyboard()
    |> Message.send(chat["id"])
  end

  # ── /photo ─────────────────────────────────────────────────────────
  # Photo by URL with caption
  def handle_message(%{text: "/photo", chat: chat}, ctx) do
    ctx
    |> Photo.url("https://picsum.photos/600/400")
    |> Photo.caption("Random photo via *picsum.photos*", "Markdown")
    |> Photo.send(chat["id"])
  end

  # ── /document ──────────────────────────────────────────────────────
  # Document from local file
  def handle_message(%{text: "/document", chat: chat}, ctx) do
    ctx
    |> Document.path("mix.exs")
    |> Document.caption("This bot's `mix.exs` sent as a document", "Markdown")
    |> Document.send(chat["id"])
  end

  # ── /sticker ───────────────────────────────────────────────────────
  # Sticker from local file
  def handle_message(%{text: "/sticker", chat: chat}, ctx) do
    ctx
    |> Sticker.path("assets/sticker.webp")
    |> Sticker.send(chat["id"])
  end

  # ── /video ─────────────────────────────────────────────────────────
  # Video from local file
  def handle_message(%{text: "/video", chat: chat}, ctx) do
    ctx
    |> Video.path("assets/video.mp4")
    |> Video.send(chat["id"])
  end

  # ── /location ──────────────────────────────────────────────────────
  def handle_message(%{text: "/location", chat: chat}, ctx) do
    ctx
    |> Location.coordinates(48.8566, 2.3522)
    |> Location.send(chat["id"])
  end

  # ── /contact ───────────────────────────────────────────────────────
  def handle_message(%{text: "/contact", chat: chat}, ctx) do
    ctx
    |> Contact.contact("Telegram", "Ex", "+10000000000")
    |> Contact.send(chat["id"])
  end

  # ── /silent ────────────────────────────────────────────────────────
  def handle_message(%{text: "/silent", chat: chat}, ctx) do
    ctx
    |> Message.text("This message was sent silently (no notification).")
    |> Message.silent()
    |> Message.send(chat["id"])
  end

  # ── /admin ─────────────────────────────────────────────────────────
  # FSM transition → :admin state (handled in Admin router)
  def handle_message(%{text: "/admin", chat: chat}, ctx) do
    ctx
    |> Message.text(
      "Entering *admin mode*.\nAny text will be echoed as an admin command.\nSend /exit to leave.",
      "Markdown"
    )
    |> Message.send(chat["id"])

    {:transition, :admin}
  end

  # ── /survey ────────────────────────────────────────────────────────
  # FSM transition → :survey_name state with initial data (handled in Survey router)
  def handle_message(%{text: "/survey", chat: chat}, ctx) do
    ctx
    |> Message.text("*Survey started!*\n\nWhat is your name?", "Markdown")
    |> Message.send(chat["id"])

    {:transition, :survey_name, %{}}
  end

  # ── Callback queries ───────────────────────────────────────────────

  def handle_callback(%{data: "vote_like", message: %{chat: chat}} = cb, ctx) do
    ctx
    |> Message.text("👍 You liked it!")
    |> Message.answer_callback_query(cb)
    |> Message.send(chat["id"])
  end

  def handle_callback(%{data: "vote_dislike", message: %{chat: chat}} = cb, ctx) do
    ctx
    |> Message.text("👎 You disliked it!")
    |> Message.answer_callback_query(cb)
    |> Message.send(chat["id"])
  end

  def handle_callback(%{data: "info", message: %{chat: chat}} = cb, ctx) do
    ctx
    |> Message.text(
      "ℹ️ This bot demonstrates all TelegramEx features:\nBuilders, keyboards, FSM, routers, callbacks."
    )
    |> Message.answer_callback_query(cb)
    |> Message.send(chat["id"])
  end

  def handle_callback(%{data: "cancel", message: %{chat: chat}} = cb, ctx) do
    ctx
    |> Message.text("❌ Action cancelled.")
    |> Message.answer_callback_query(cb)
    |> Message.send(chat["id"])
  end

  # ── Reply keyboard echo ───────────────────────────────────────────
  def handle_message(%{text: "Option " <> letter, chat: chat}, ctx)
      when letter in ["A", "B", "C"] do
    ctx
    |> Message.text("You selected: *Option #{letter}*", "Markdown")
    |> Message.send(chat["id"])
  end
end
