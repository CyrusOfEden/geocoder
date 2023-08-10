defmodule Geocoder.ConfigTest do
  use ExUnit.Case, async: true

  alias Geocoder.Config

  describe "all/1" do
    test "returns the default configuration" do
      assert Config.all() == [
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
                 http_client_opts: [recv_timeout: 30_000],
                 json_codec: Jason,
                 data: nil
               ]
             ]
    end

    test "can override the pool name configuration" do
      assert Config.all(pool_name: :toto) == [
               pool_name: :toto,
               pool_config: [
                 worker_module: Geocoder.Worker,
                 size: 4,
                 max_overflow: 2,
                 strategy: :lifo,
                 name: {:local, :toto}
               ],
               store_module: Geocoder.Store,
               store_config: [name: :geocoder_store, precision: 6],
               worker_config: [
                 provider: Geocoder.Providers.OpenStreetMaps,
                 key: nil,
                 http_client: Geocoder.HttpClient.Httpoison,
                 http_client_opts: [recv_timeout: 30_000],
                 json_codec: Jason,
                 data: nil
               ]
             ]
    end

    test "can override the store configuration" do
      assert Config.all(store_config: [precision: 3]) == [
               pool_name: :geocoder_workers,
               pool_config: [
                 worker_module: Geocoder.Worker,
                 size: 4,
                 max_overflow: 2,
                 strategy: :lifo,
                 name: {:local, :geocoder_workers}
               ],
               store_module: Geocoder.Store,
               store_config: [name: :geocoder_store, precision: 3],
               worker_config: [
                 provider: Geocoder.Providers.OpenStreetMaps,
                 key: nil,
                 http_client: Geocoder.HttpClient.Httpoison,
                 http_client_opts: [recv_timeout: 30_000],
                 json_codec: Jason,
                 data: nil
               ]
             ]
    end

    test "can override the pool configuration" do
      assert Config.all(
               pool_config: [
                 worker_module: Geocoder.MyWorker,
                 size: 1,
                 max_overflow: 1,
                 strategy: :fifo
               ]
             ) == [
               pool_name: :geocoder_workers,
               pool_config: [
                 name: {:local, :geocoder_workers},
                 worker_module: Geocoder.MyWorker,
                 size: 1,
                 max_overflow: 1,
                 strategy: :fifo
               ],
               store_module: Geocoder.Store,
               store_config: [name: :geocoder_store, precision: 6],
               worker_config: [
                 provider: Geocoder.Providers.OpenStreetMaps,
                 key: nil,
                 http_client: Geocoder.HttpClient.Httpoison,
                 http_client_opts: [recv_timeout: 30_000],
                 json_codec: Jason,
                 data: nil
               ]
             ]
    end

    test "can override the worker configuration" do
      assert Config.all(
               worker_config: [
                 provider: Geocoder.Providers.Google,
                 key: "somekey",
                 http_client: Geocoder.HttpClient.Hackney,
                 http_client_opts: [timeout: 30_000]
               ]
             ) == [
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
                 json_codec: Jason,
                 data: nil,
                 provider: Geocoder.Providers.Google,
                 key: "somekey",
                 http_client: Geocoder.HttpClient.Hackney,
                 http_client_opts: [timeout: 30_000]
               ]
             ]
    end
  end
end
