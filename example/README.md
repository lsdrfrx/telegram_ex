# TelegramEx Demo Bot

A demo bot that showcases every feature of the [TelegramEx](https://github.com/lsdrfrx/telegram_ex) library.

## Features Demonstrated

| Command      | Feature                               |
| ------------ | ------------------------------------- |
| `/start`     | Reply keyboard with all commands      |
| `/help`      | HTML-formatted help message           |
| `/text`      | Plain text message                    |
| `/markdown`  | Markdown parse mode                   |
| `/html`      | HTML parse mode                       |
| `/keyboard`  | Inline keyboard + callback handling   |
| `/reply_kb`  | Reply keyboard (one-time, resizable)  |
| `/remove_kb` | Remove reply keyboard                 |
| `/photo`     | Photo from URL with caption           |
| `/document`  | Document from local file              |
| `/sticker`   | Sticker from local `.webp` file       |
| `/video`     | Video from local file                 |
| `/location`  | Send geo coordinates (Paris)          |
| `/contact`   | Send a contact card                   |
| `/silent`    | Silent message (no notification)      |
| `/admin`     | Router + FSM: admin mode              |
| `/survey`    | Multi-step FSM with data accumulation |

## Running

```bash
TOKEN=your_bot_token mix run --no-halt
```
