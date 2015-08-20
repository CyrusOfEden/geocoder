defmodule Geocoder.Store do
  use GenServer
  use Towel

  @name :geocoder_store

  # Public API
  def state do
    GenServer.call @name, :state
  end

  def geocode(address) do
    GenServer.call @name, {:geocode, address}
  end

  def reverse_geocode(latlon) do
    GenServer.call @name, {:reverse_geocode, latlon}
  end

  def update(coords) do
    GenServer.cast @name, {:update, coords}
  end

  def link(from, to) do
    GenServer.cast @name, {:link, from, to}
  end

  # GenServer API
  def start_link(state \\ nil) do
    # {links, store, bounds}
    GenServer.start_link(__MODULE__, state || {%{}, %{}, []}, name: @name)
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:geocode, key}, _from, state = {links,store,_}) do
    result = get_link(links, key) |> fmap(&Map.get(store, &1))
    {:reply, result, state}
  end

  def handle_call({:reverse_geocode, latlon}, _from, state = {links,store,bounds}) do
    result = case get_link(links, latlon) do
      {:ok, key}  ->
        get_value(store, key)
      {:error, _} ->
        find_cached_bound(bounds, latlon)
        |> bind(&get_value(store, &1))
    end
    {:reply, result, state}
  end

  def handle_cast({:update, coords}, store) do
    {:noreply, update_store(store, coords)}
  end

  def handle_cast({:link, from, to}, store) do
    {:noreply, add_link(store, from, to)}
  end

  defp get_value(store, key) do
    wrap(Map.get(store, key))
  end

  defp get_link(links, key) do
    wrap(links) |> fmap(&Map.get(&1, encode_key(key)))
  end

  defp add_link({links, store, bounds}, from, to) do
    links = Map.put(links, encode_key(from), encode_key(to))

    {links, store, bounds}
  end

  defp update_store({links, store, bounds}, coords) do
    key = encode_key(coords)

    links = Map.put(links, key, key)
    store = Map.put(store, key, coords)
    unless is_nil(coords.bounds.top) or is_nil(coords.bounds.right) or
           is_nil(coords.bounds.bottom) or is_nil(coords.bounds.left) do
      bounds = [{key, coords.bounds}|bounds]
    end

    {links, store, bounds}
  end

  defp find_cached_bound(bounds, {lat,lon}) do
    wrap(bounds)
    |> fmap(&Enum.find(&1, fn {_,bounds} ->
      lat <= bounds.top and lat >= bounds.bottom and
      lon <= bounds.right and lon >= bounds.left
    end))
    |> fmap(&elem(&1, 0))
  end

  defp encode_key(string) when is_binary(string) do
    string
    |> String.replace(~r/[^\w]/, "")
    |> String.downcase
  end

  defp encode_key(%{location: %{city: city, state: state, country: country}}) do
    [city, state, country]
    |> Enum.join("")
    |> encode_key
  end

  defp encode_key({lat,lon}) do
    round = &Float.round(&1, 8)
    "#{round.(lat)},#{round.(lon)}"
  end
end