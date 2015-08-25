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
    {:reply, fmap(get_link(links, key), &Map.get(store, &1)), state}
  end

  def handle_call({:reverse_geocode, latlon}, _from, state = {links,store,bounds}) do
    case get_link(links, latlon) do
      {:just, key} ->
        {:reply, get_value(store, key), state}
      :nothing ->
        {:reply, bind(find_cached_bound(bounds, latlon), &get_value(store, &1)), state}
    end
  end

  def handle_cast({:update, coords}, store) do
    {:noreply, update_store(store, coords)}
  end

  def handle_cast({:link, from, to}, store = {links,_,_}) do
    links = put_link(links, from, encode_key(to.location))
    {:noreply, put_elem(store, 0, links)}
  end

  # Private API
  defp cached?(store, coords) do
    Map.has_key?(store, encode_key(coords))
  end

  defp get_value(store, key) do
    store |> Map.get(key) |> Maybe.wrap
  end

  defp get_link(links, key) do
    links |> Map.get(encode_key(key)) |> Maybe.wrap
  end

  defp put_link(links, from, to) do
    Map.put(links, encode_key(from), encode_key(to))
  end

  defp put_links(links, coords, key) do
    List.foldl link_keys(coords), links, &put_link(&2, &1, key)
  end

  defp update_store({links,store,bounds}, coords) do
    key = encode_key(coords.location)

    if valid_bounds(coords.bounds) and not cached?(store, key) do
      bounds = [{key, coords.bounds}|bounds]
    end
    links = put_links(links, coords, key)
    store = Map.put(store, key, coords)

    {links, store, bounds}
  end

  defp find_cached_bound(bounds, coords) do
    bounds
    |> Enum.find(&within_bounds(coords, elem(&1, 1)))
    |> Maybe.wrap
    |> fmap(&elem(&1, 0))
  end

  defp within_bounds({lat,lon}, %{top: top, right: right, bottom: bottom, left: left}) do
    lat <= top and lat >= bottom and
    lon <= right and lon >= left
  end

  defp valid_bounds(%{top: top, right: right, bottom: bottom, left: left}) do
    not (is_nil(top) or is_nil(right) or is_nil(bottom) or is_nil(left))
  end

  defp encode_key(string) when is_binary(string) do
    string
    |> String.replace(~r/[^\w]/, "")
    |> String.downcase
  end

  defp encode_key(%{lat: lat, lon: lon}) do
    encode_key({lat,lon})
  end
  defp encode_key({lat,lon}) do
    round = &Float.round(&1, 3)
    "#{round.(lat)},#{round.(lon)}"
  end

  defp encode_key(%{city: city, state: state, country: country}) do
    [city, state, country]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("")
    |> encode_key
  end

  defp link_keys(coords) do
    location = coords.location
    city = Map.get(location, :city)

    [city, location, coords]
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&encode_key/1)
  end
end