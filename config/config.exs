use Mix.Config

config :geocoder, :worker_pool_config, [
  size: 4,
  max_overflow: 2
]
