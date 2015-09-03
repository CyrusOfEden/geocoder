defmodule Geocoder.Worker do
  use GenServer
  use Towel

  # Public API
  def geocode(address, opts \\ []) do
    assign(:geocode, address, opts)
  end

  def reverse_geocode(latlon, opts \\ []) do
    assign(:reverse_geocode, latlon, opts)
  end

  # GenServer API
  @worker_defaults [
    store: Geocoder.Store,
    provider: Geocoder.Providers.GoogleMaps
  ]
  def init(opts) do
    {:ok, Keyword.merge(@worker_defaults, opts)}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def handle_call({function, param, req}, _from, opts) do
    {:reply, run(function, param, opts, req[:store]), opts}
  end

  def handle_cast({function, param, req}, opts) do
    Task.start_link fn ->
      send(req[:stream_to], run(function, param, opts, req[:store]))
    end
    {:noreply, opts}
  end

  # Private API
  @assign_defaults [
    timeout: 5000,
    stream_to: nil,
    store: true
  ]

  defp assign(name, param, opts) do
    opts = Keyword.merge(@assign_defaults, opts)

    function = case {opts[:stream_to], {name, param, opts}} do
      {nil, message} -> &GenServer.call(&1, message)
      {_,   message} -> &GenServer.cast(&1, message)
    end

    :poolboy.transaction(Geocoder.pool_name, function, opts[:timeout])
  end

  defp run(function, param, opts, false) do
    apply(opts[:provider], function, [param])
    |> tap(&opts[:store].update/1)
    |> tap(&opts[:store].link(param, &1))
  end
  defp run(function, param, opts, true) do
    case apply(opts[:store], function, [param]) do
      {:just, coords} ->
        ok(coords)
      :nothing ->
        run(function, param, opts, false)
    end
  end
end