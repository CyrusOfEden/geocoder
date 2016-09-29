use Mix.Config

config :geocoder, :worker_pool_config, [
  size: 4,
  max_overflow: 2
]

config :geocoder, :worker, [
  provider: Geocoder.GoogleMaps # OpenStreetMaps
]
