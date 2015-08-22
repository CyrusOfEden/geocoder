defmodule Geocoder.Worker do
  use GenServer
  use Towel

  @defaults [
    timeout: 5000,
    stream_to: nil,
  ]

  # Public API
  def call(q, opts \\ [])
  def call(q, opts) when is_binary(q), do: geocode(q, opts)
  def call(q = {_,_}, opts), do: reverse_geocode(q, opts)

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

  def handle_call({function, param, _req_options}, _from, opts) do
    {:reply, run(function, param, opts), opts}
  end

  def handle_cast({function, param, req_options}, opts) do
    send(req_options[:stream_to], run(function, param, opts))
    {:noreply, opts}
  end

  defp run(function, param, [store: store, provider: provider]) do
    case apply(store, function, [param]) do
      {:just, coords} ->
        ok(coords)
      :nothing ->
        apply(provider, function, [param])
        |> tap(&store.update/1)
        |> tap(&store.link(param, &1))
    end
  end
end