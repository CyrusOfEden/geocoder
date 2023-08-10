defmodule Geocoder.Config do
  @moduledoc """
  Centralization of configurations and defaults values.

  The following options are available for configuration.

    * `:pool_name` - The name for the pool.
    * `:pool_config` - The configuration for the pool. It uses Poolboy behind the scene, so the following configuration key exists.
    * `:store_module` - The store module to use. Defaults to `Geocoder.Store`
    * `:store_config` - The store configuration
    * `:worker_config` - The worker configuration. Things like the provider, key, or even custom JSON codec or HTTP clients

  Here is full example of a configuration (with all the defaults)

  ```elixir
  [
    pool_name: :geocoder_workers,
    pool_config: [
      worker_module: Geocoder.Worker,
      size: 4,
      max_overflow: 2,
      strategy: :lifo,
      name: {:local, :geocoder_workers}
    ],
    store_module: Geocoder.Store,
    store_config: [name: :geocoder_store, precision: 6],
    worker_config: [
      provider: Geocoder.Providers.OpenStreetMaps,
      key: nil,
      http_client: Geocoder.HttpClient.Httpoison,
      http_client_opts: [recv_timeout: 30000],
      json_codec: Jason,
      data: nil
    ]
  ]
  ```
  """
  @type pool_option ::
          {:worker_module, module()}
          | {:size, pos_integer()}
          | {:max_overflow, pos_integer()}
          | {:strategy, :fifo | :lifo}
          | {:name, atom() | {atom(), atom()}}

  @type pool_config :: [pool_option()]

  @type store_option ::
          {:name, atom()}
          | {:precision, pos_integer()}

  @type store_config :: [store_option()]

  @type worker_option ::
          {:provider, module()}
          | {:key, binary()}
          | {:http_client, module()}
          | {:http_client_opts, keyword()}
          | {:json_codec, module()}
          | {:data, map()}

  @type worker_config :: [worker_option()]
  @type geocoder_option ::
          {:pool_name, atom()}
          | {:pool_config, pool_config()}
          | {:store_module, module()}
          | {:store_config, store_config()}
          | {:worker_config, worker_config()}

  @type geocoder_config :: [geocoder_option]

  @default_pool_name :geocoder_workers

  @default_pool_config [
    name: {:local, @default_pool_name},
    worker_module: Geocoder.Worker,
    size: 4,
    max_overflow: 2,
    strategy: :lifo
  ]

  @default_http_client_opts [recv_timeout: 30_000]

  @default_worker_config [
    provider: Geocoder.Providers.OpenStreetMaps,
    key: nil,
    http_client: Geocoder.HttpClient.Httpoison,
    http_client_opts: @default_http_client_opts,
    json_codec: Jason,
    data: nil
  ]

  @default_store_name :geocoder_store

  @default_store_config [
    name: @default_store_name,
    precision: 6
  ]

  @default_store_module Geocoder.Store

  @spec default_store_name :: :geocoder_store
  def default_store_name, do: @default_store_name

  @spec default_pool_name :: :geocoder_workers
  def default_pool_name, do: @default_pool_name

  @spec all(geocoder_config()) :: geocoder_config()
  def all(opts \\ []) do
    [
      pool_name: pool_name(opts),
      pool_config: pool_config(opts),
      store_module: store_module(opts),
      store_config: store_config(opts),
      worker_config: worker_config(opts)
    ]
  end

  @spec pool_name(geocoder_config()) :: atom()
  def pool_name(opts \\ []) do
    Keyword.get(opts, :pool_name, @default_pool_name)
  end

  @spec pool_config(geocoder_config()) :: pool_config()
  def pool_config(opts \\ []) do
    pool_config_name = pool_name(opts)

    pool_config =
      opts |> Keyword.get(:pool_config, []) |> Keyword.put(:name, {:local, pool_config_name})

    Keyword.merge(@default_pool_config, pool_config)
  end

  @spec worker_config(geocoder_config()) :: worker_config()
  def worker_config(opts \\ []) do
    Keyword.merge(@default_worker_config, opts[:worker_config] || [])
  end

  @spec store_module(geocoder_config()) :: atom()
  def store_module(opts \\ []) do
    Keyword.get(opts, :store_module, @default_store_module)
  end

  @spec worker_config(geocoder_config()) :: store_config()
  def store_config(opts \\ []) do
    Keyword.merge(@default_store_config, opts[:store_config] || [])
  end
end
