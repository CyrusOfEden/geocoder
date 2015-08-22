defmodule Geocoder.Mixfile do
  use Mix.Project

  def project do
    [app: :geocoder,
     description: "A simple, efficient geocoder/reverse geocoder with a built-in cache.",
     version: "0.1.1",
     elixir: "~> 1.0",
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def package do
    [licenses: ["MIT"],
     contributors: ["Kash Nouroozi"],
     links: %{"Github" => "https://github.com/knrz/geocoder"}]
  end

  def application do
    [applications: [:logger, :httpoison],
     mod: {Geocoder, []}]
  end

  defp deps do
    [{:httpoison, "~> 0.7"},
     {:poison, "~> 1.4"},
     {:towel, "~> 0.2"}]
  end
end
