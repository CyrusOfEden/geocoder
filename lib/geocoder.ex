defmodule Geocoder do
  use Application

  def pool_name, do: :geocoder_workers
  def config do
    [worker_module: Geocoder.Worker, name: {:local, pool_name}]
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
end
