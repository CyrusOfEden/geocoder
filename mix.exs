defmodule Geocoder.Mixfile do
  use Mix.Project

  def project do
    [app: :geocoder,
     description: "A simple, efficient geocoder/reverse geocoder with a built-in cache.",
     version: "0.3.0",
     elixir: "~> 1.0",
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def package do
    [licenses: ["MIT"],
     contributors: ["Kash Nouroozi"],
     links: %{"GitHub" => "https://github.com/knrz/geocoder"}]
  end

  def application do
    [applications: [:logger, :poolboy, :httpoison],
     mod: {Geocoder, []}]
  end

  defp deps do
    [{:httpoison, "~> 0.7"},
     {:poison, "~> 1.4"},
     {:towel, "~> 0.2"},
     {:poolboy, "~> 1.5"}]
  end
end
