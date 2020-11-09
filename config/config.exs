use Mix.Config

config :geocoder, :worker_pool_config,
  size: 4,
  max_overflow: 2

case System.get_env("PROVIDER", "openstreetmaps") do
  "google" ->
    config :geocoder, :worker,
      provider: Geocoder.Providers.GoogleMaps,
      key: System.get_env("API_KEY", "NO_API_KEY")

  "opencagedata" ->
    config :geocoder, :worker,
      provider: Geocoder.Providers.OpenCageData,
      key: System.get_env("API_KEY", "NO_API_KEY")

  "openstreetmaps" ->
    config :geocoder, :worker, provider: Geocoder.Providers.OpenStreetMaps
end
