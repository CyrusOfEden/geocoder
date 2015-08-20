defmodule Geocoder.Mixfile do
  use Mix.Project

  def project do
    [app: :geocoder,
     version: "0.0.1",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :httpoison],
     mod: {Geocoder, []}]
  end

  defp deps do
    [{:httpoison, "~> 0.7"},
     {:poison, "~> 1.4"},
     {:towel, "~> 0.0.1"}]
  end
end
