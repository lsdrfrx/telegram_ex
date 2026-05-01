defmodule TelegramEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :telegram_ex,
      name: "TelegramEx",
      version: "1.2.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      package: package(),
      description: description(),
      deps: deps(),
      dialyzer: dialyzer(),
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
      {:pockets, "~> 1.5.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_local_path: "priv/plts/project.plt",
      plt_core_path: "priv/plts/core.plt",
      flags: [:error_handling, :missing_return, :extra_return, :underspecs]
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
