defmodule Geocoder.Mixfile do
  use Mix.Project

  def project do
    [
      app: :geocoder,
      description: "A simple, efficient geocoder/reverse geocoder with a built-in cache.",
      source_url: "https://github.com/knrz/geocoder",
      homepage_url: "https://github.com/knrz/geocoder",
      version: "1.0.0",
      elixir: "~> 1.6",
      otp: "~> 20",
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      deps: deps()
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      maintainers: ["Kash Nouroozi", "Arjan Scherpenisse"],
      links: %{"GitHub" => "https://github.com/knrz/geocoder"}
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Geocoder, []}
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.5"},
      {:poison, "~> 4.0"},
      {:towel, "~> 0.2"},
      {:poolboy, "~> 1.5"},
      {:geohash, "~> 1.2"},
      {:ex_doc, "~> 0.19", only: :dev},
      {:inch_ex, ">= 0.0.0", only: :docs},
      {:excoveralls, "~> 0.6.3", only: :test}
    ]
  end
end
