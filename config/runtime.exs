import Config

config :telegram_ex,
  echo_bot: System.fetch_env!("TOKEN")
