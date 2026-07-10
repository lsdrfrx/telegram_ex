# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## 1.3.0 - 10-07-2026

### Added

- `defcommand` macro for defining commands with arguments and options
- Automatic registration of commands via Telegram `setMyCommands`
- `TelegramEx.Error` struct to describe API errors
- `TelegramEx.Effect` for pipeline-friendly builders with short-circuiting errors
- `TelegramEx.Builder.Voice` for sending voice messages by file ID, URL, or local file path
- `TelegramEx.MimeType` for resolving uploaded file content types from extensions
- `audio` and `reply_to_message` fields in `TelegramEx.Types.Message`
- Detailed guides for commands, effects, examples, FSM, routers, media, development, and getting started
- Contribution guidelines in `CONTRIBUTING.md`

### Changed

- Builders now accept either a raw handler context or an existing `TelegramEx.Effect`
- File payload handling is shared through `TelegramEx.Builder.put_file_payload/3`
- Local media uploads now use extension-based MIME types instead of hardcoded content types
- API error responses are returned as structured `TelegramEx.Error` values

### Fixed

- Added a `from_map/1` clause for `nil` nested messages to avoid failures when optional reply messages are absent
- Fixed Dialyzer issues in message conversion specs

## 1.2.1 - 18-05-2026

### Added

- `TelegramEx.Builder.Poll` for sending polls and quizzes
- Proper library documentation

## [1.2.0] - 13-04-2026

### Added

- `TelegramEx.Builder.Sticker` for sending stickers (by id, url, file path)
- `TelegramEx.Builder.Location` for sending geo coordinates
- `TelegramEx.Builder.Video` for sending videos (by id, url, file path) with duration and cover support
- `TelegramEx.Builder.Contact` for sending contacts
- Example project in `example/` folder as quick review of all features
- Sending messages to concrete threads in forum chats via `message_thread_id`
- `TelegramEx.Router` macro to group handlers by logic into routers

### Changed

- All builders now accept `ctx` as the first argument and store payload inside `ctx.payload`
- `API.request/1` accepts full context map instead of separate `token`, `method`, `payload` arguments
- Builders' `send/2` delegates to `API.request/1` through context — no more `Process.get(:token)`

## [1.1.0] - 27-03-2026

### Added

- `TelegramEx.FSM` module with `defstate/2` macro to make stateful handlers
- Multiple bot support via names
- Fallback update handlers

## [1.0.0] - 08-03-2026

### Added

- `TelegramEx` macro for wrapping user module into GenServer
- Polling updates inside `TelegramEx.Server`
- Applying all user-defined handlers inside `TelegramEx` to updates in `TelegramEx.Server`
- Performing actions in declarative way with `Message`, `Photo`, `Document` builders
- Reply markup support via `Message.reply_keyboard`
- Inline markup support via `Message.inline_keyboard`
- Handling callback queries and messages
