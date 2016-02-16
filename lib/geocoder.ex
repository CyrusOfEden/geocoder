defmodule Geocoder do
  use Application

  @pool_name :geocoder_workers
  @default_config [worker_module: Geocoder.Worker, name: {:local, @pool_name}]

  def pool_name, do: @pool_name
  def worker_config do
    Keyword.merge(Application.get_env(:geocoder, Geocoder.Worker) || [],
                  @default_config)
  end

  def store_config do
    Application.get_env(:geocoder, Geocoder.Store) || []
  end

  def start(_type, _opts) do
    import Supervisor.Spec

    children = [
      :poolboy.child_spec(pool_name, worker_config, []),
      worker(Geocoder.Store, [store_config])
    ]

    options = [
      strategy: :one_for_one,
      name: Geocoder.Supervisor
    ]

    Supervisor.start_link(children, options)
  end

  alias Geocoder.Worker

  def call(q, opts \\ [])
  def call(q, opts) when is_binary(q), do: Worker.geocode(q, opts)
  def call(q = {_,_}, opts), do: Worker.reverse_geocode(q, opts)
  
  def call_list(q, opts \\ [])
  def call_list(q = {_,_}, opts), do: Worker.reverse_geocode_list(q, opts)
  def call_list(q, opts) when is_binary(q), do: Worker.geocode_list(q, opts)
end
