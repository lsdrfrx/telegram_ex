# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `TelegramEx.FSM` module with `defstate/2` macro to make stateful handlers
- Multiple bot support via names
- Fallback update handlers

## [1.0.0]

### Added
- `TelegramEx` macro for wrapping user module into GenServer
- Polling updates inside `TelegramEx.Server`
- Applying all user-defined handlers inside `TelegramEx` to updates in `TelegramEx.Server`
- Performing actions in declarative way with `Message`, `Photo`, `Document` builders
- Reply markup support via `Message.reply_keyboard`
- Inline markup support via `Message.inline_keyboard`
- Handling callback queries and messages
