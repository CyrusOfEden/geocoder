defmodule Geocoder.Worker do
  use GenServer
  use Towel

  @name :geocoder_worker

  # Public API
  def call(q) when is_binary(q), do: geocode(q)
  def call(q = {_,_}), do: reverse_geocode(q)

  def geocode(address) do
    GenServer.call(@name, {:geocode, address})
  end

  def reverse_geocode(latlon) do
    GenServer.call(@name, {:reverse_geocode, latlon})
  end

  # GenServer API
  @defaults [
    store: Geocoder.Store,
    provider: Geocoder.Providers.GoogleMaps
  ]
  def start_link(opts) do
    opts = Keyword.merge(@defaults, opts)
    GenServer.start_link(__MODULE__, opts, name: @name)
  end

  def handle_call({:geocode, address}, _from, opts) do
    case opts[:store].geocode(address) do
      {:just, coords} ->
        {:reply, ok(coords), opts}
      :nothing ->
        {:reply, get_and_update(opts, :geocode, address), opts}
    end
  end

  def handle_call({:reverse_geocode, latlon}, _from, opts) do
    case opts[:store].reverse_geocode(latlon) do
      {:just, coords} ->
        {:reply, ok(coords), opts}
      :nothing ->
        {:reply, get_and_update(opts, :reverse_geocode, latlon), opts}
    end
  end

  # Private API
  defp get_and_update([store: store, provider: provider], function, name) do
    apply(provider, function, [name])
    |> tap(&store.update/1)
    |> tap(&store.link(name, &1))
  end
end