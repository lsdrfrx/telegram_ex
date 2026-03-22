defmodule TelegramEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :telegram_ex,
      name: "TelegramEx",
      version: "1.0.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: deps(),
      source_url: "https://github.com/lsdrfrx/telegram_ex"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:req, "~> 0.5"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Elixir library for building Telegram bots with macro-based API"
  end

  defp package do
    [
      name: "telegram_ex",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*
                CHANGELOG*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/lsdrfrx/telegram_ex"}
    ]
  end
end
