defmodule Geocoder.Mixfile do
  use Mix.Project

  def project do
    [app: :geocoder,
     description: "A simple, efficient geocoder/reverse geocoder with a built-in cache.",
     version: "0.4.1",
     elixir: "~> 1.2",
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
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
     {:poison, "~> 1.5"},
     {:towel, "~> 0.2"},
     {:poolboy, "~> 1.5"},
     {:geohash, "~> 0.1"}]
  end
end
