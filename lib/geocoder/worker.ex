defmodule Geocoder.Worker do
  use GenServer
  use Towel

  @defaults [
    timeout: 5000,
    stream_to: nil,
    store: true
  ]

  # Public API
  def geocode(address, opts \\ []) do
    opts = Keyword.merge(@defaults, opts)
    assign(:geocode, address, opts)
  end

  def reverse_geocode(latlon, opts \\ []) do
    opts = Keyword.merge(@defaults, opts)
    assign(:reverse_geocode, latlon, opts)
  end

  defp assign(name, param, opts) do
    function = case {opts[:stream_to], {name, param, opts}} do
      {nil, message} -> &GenServer.call(&1, message)
      {_,   message} -> &GenServer.cast(&1, message)
    end

    :poolboy.transaction Geocoder.pool_name, function, opts[:timeout]
  end

  # GenServer API
  def start_link(_) do
    opts = [
      store: Geocoder.Store,
      provider: Geocoder.Providers.GoogleMaps
    ]
    GenServer.start_link(__MODULE__, opts)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({function, param, req}, _from, opts) do
    {:reply, run(function, param, opts, req[:store]), opts}
  end

  def handle_cast({function, param, req}, opts) do
    send(req[:stream_to], run(function, param, opts, req[:store]))
    {:noreply, opts}
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