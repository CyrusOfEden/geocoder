defmodule Geocoder.Mixfile do
  use Mix.Project

  def project do
    [app: :geocoder,
     description: "A simple, efficient geocoder/reverse geocoder with a built-in cache.",
     version: "0.7.0",
     elixir: "~> 1.2",
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
     deps: deps()]
  end

  def package do
    [licenses: ["MIT"],
     maintainers: ["Kash Nouroozi", "Arjan Scherpenisse"],
     links: %{"GitHub" => "https://github.com/knrz/geocoder"}]
  end

  def application do
    [applications: [:logger, :poolboy, :httpoison, :geohash],
     mod: {Geocoder, []}]
  end

  defp deps do
    [{:httpoison, "~> 0.8"},
     {:poison, "< 4.0.0"},
     {:towel, "~> 0.2"},
     {:poolboy, "~> 1.5"},
     {:geohash, "~> 0.1"},
     {:ex_doc, ">= 0.0.0", only: :dev},
     {:inch_ex, ">= 0.0.0", only: :docs},
     {:excoveralls, "~> 0.6.3", only: :test}]
  end
end
