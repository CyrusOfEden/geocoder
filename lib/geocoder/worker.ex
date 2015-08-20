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
    result = case opts[:store].geocode(address) do
      {:ok, coords} ->
        ok(coords)
      {:error, _} ->
        get_and_update(opts[:store], opts[:provider], :geocode, address)
        |> fmap(fn coords ->
          opts[:store].link(address, coords)
          coords
        end)
    end
    {:reply, result, opts}
  end

  def handle_call({:reverse_geocode, latlon}, _from, opts) do
    result = case opts[:store].reverse_geocode(latlon) do
      {:ok, coords} ->
        ok(coords)
      {:error, _} ->
        get_and_update(opts[:store], opts[:provider], :reverse_geocode, latlon)
        |> fmap(fn coords ->
          opts[:store].link(latlon, coords)
          coords
        end)
    end
    {:reply, result, opts}
  end

  # Private API
  defp get_and_update(store, provider, function, args) do
    case apply(provider, function, List.wrap(args)) do
      {:ok, coords} ->
        store.update(coords)
        ok(coords)
      {:error, reason} ->
        error(reason)
    end
  end
end