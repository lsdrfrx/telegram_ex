import Config

config :telegram_ex,
  name: "test",
  token: System.fetch_env!("TOKEN")
