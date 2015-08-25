defmodule Geocoder do
  use Application

  def pool_name, do: :geocoder_workers
  def config do
    Application.get_env(:geocoder, :worker_pool_config)
    |> Enum.into([
      worker_module: Geocoder.Worker,
      name: {:local, pool_name}
    ])
  end

  def start(_type, _opts) do
    import Supervisor.Spec

    children = [
      :poolboy.child_spec(pool_name, config, []),
      worker(Geocoder.Store, [])
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
end
