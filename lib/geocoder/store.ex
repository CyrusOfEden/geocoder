defmodule Geocoder.Store do
  use GenServer
  use Towel

  # Public API
  def geocode(opts) do
    GenServer.call(name, {:geocode, opts[:address]})
  end

  def reverse_geocode(opts) do
    GenServer.call(name, {:reverse_geocode, opts[:latlng]})
  end

  def update(data) do
    GenServer.call(name, {:update, data})
  end

  def link(from, to) do
    GenServer.cast(name, {:link, from, to})
  end

  def state do
    GenServer.call(name, :state)
  end

  # GenServer API
  @defaults [precision: 4]
  def start_link(opts \\ []) do
    opts = Keyword.merge(@defaults, opts)
    GenServer.start_link(__MODULE__, {%{}, %{}, opts}, [name: name])
  end

  # Fetch geocode
  def handle_call({:geocode, location}, _from, {links,store,_} = state) do
    key = encode(location)
    result = Maybe.wrap(links) |> fmap(&Map.get(&1, key)) |> fmap(&Map.get(store, &1))
    {:reply, result, state}
  end

  # Fetch reverse geocode
  def handle_call({:reverse_geocode, latlon}, _from, {_,store,opts} = state) do
    key = encode(latlon, opts[:precision])
    result = Maybe.wrap(store) |> fmap(&Map.get(&1, key))
    {:reply, result, state}
  end

  # Update store
  def handle_call({:update, data}, from, {links, store, opts}) when is_list(data) do
    map = data |> Enum.reduce(%{links: links, store: store}, fn e, acc ->
                    {l, s} = update_single(acc[:store], acc[:links], e, opts[:precision])
                    %{links: l, store: s}
                  end)
    {:reply, data, {map[:links], map[:store], opts}}
  end

  def handle_call({:update, data}, _from, {links, store, opts}) do
    {links, store} = update_single(store, links, data, opts[:precision])
    {:reply, data, {links, store, opts}}
  end

  #  state = {Map.put(links, link, key), Map.put(store, key, data), opts}
  #  {:reply, data, state}
  #end

  # Get the state
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  # Link a query to a cached values (many values)
  def handle_cast({:link, from, data}, {links, store, opts}) when is_list(data) do
    map = data |> Enum.reduce(links, &link_single(&2, from, &1, opts[:precision]))
    {:noreply, {map, store, opts}}
  end

  # Link a query to a cached value
  def handle_cast({:link, from, data}, {links, store, opts}) do
    {:noreply, {link_single(links, from, data, opts[:precision]), store, opts}}
  end

  ##############################################################################

  # Private API
  defp encode(location, opt \\ nil)
  defp encode({lat, lon}, precision) do
    Geohash.encode(:erlang.float(lat), :erlang.float(lon), precision)
  end
  defp encode(location, _) when is_binary(location) do
    location
    |> String.downcase
    |> String.replace(~r/[^\w]/, "")
    |> String.strip
    |> :base64.encode
  end

  # Config
  @name :geocoder_store
  def name, do: @name

  ##############################################################################

  defp link_single(map, from, to, precision) do
    %Geocoder.Coords{lat: lat, lon: lon} = to |> Geocoder.Data.latlng
    Map.put_new(map, encode(from, precision), encode({lat, lon}, precision))
  end

  defp update_single(store, links, data, precision) do
    %{lat: lat, lon: lon} = data |> Geocoder.Data.latlng
    location =
      data |> Geocoder.Data.location
      |> Map.take(~w[city, state, country]a)
      |> Enum.filter_map(&is_binary(elem(&1, 1)), &elem(&1, 1))
      |> Enum.join("")

    key = encode({lat, lon}, precision)
    link = encode(location, precision)

    {Map.put_new(links, link, key), Map.put_new(store, key, data)}
  end
end
