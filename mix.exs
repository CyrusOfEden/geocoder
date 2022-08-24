defmodule Geocoder.Mixfile do
  use Mix.Project

  @source_url "https://github.com/knrz/geocoder"
  @version "1.1.4"

  def project do
    [
      app: :geocoder,
      version: @version,
      elixir: "~> 1.10",
      otp: "~> 21",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def package do
    [
      description: "A simple, efficient geocoder/reverse geocoder with a built-in cache.",
      licenses: ["MIT"],
      maintainers: ["Kash Nouroozi", "Arjan Scherpenisse", "Michael Bianco"],
      links: %{
        "Changelog" => "https://github.com/knrz/geocoder/releases",
        "GitHub" => @source_url
      }
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
      {:jason, "~> 1.2"},
      {:towel, "~> 0.2"},
      {:poolboy, "~> 1.5"},
      {:geohash, "~> 1.2"},
      {:ex_doc, "~> 0.28.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: :test}
    ]
  end

  defp docs do
    [
      extras: [
        "CODE_OF_CONDUCT.md": [title: "Code of Conduct"],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      groups_for_modules: [
        Providers: ~r/^Geocoder.Providers/,
        Structs: [Geocoder.Bounds, Geocoder.Coords, Geocoder.Location]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      homepage_url: @source_url,
      formatters: ["html"]
    ]
  end
end
