defmodule Geocoder do
  use Application

  @defaults [worker: [], store: nil]
  def start(_type, opts) do
    opts = Keyword.merge(@defaults, opts)

    import Supervisor.Spec

    children = [
      worker(Geocoder.Worker, [opts[:worker]]),
      worker(Geocoder.Store, [opts[:store]])
    ]

    opts = [strategy: :one_for_one, name: Geocoder.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defdelegate [call(q), geocode(address), reverse_geocode(latlon)], to: Geocoder.Worker
end
