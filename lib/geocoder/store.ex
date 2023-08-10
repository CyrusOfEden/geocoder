defmodule Geocoder.Store do
  @moduledoc """
  Store is used as caching mechanism and is currently implemented as an in memory storage
  so within an Elixir process basically
  """
  use GenServer
  use Towel

  alias Geocoder.Config

  def geocode(pid, params) do
    GenServer.call(pid, {:geocode, params[:address]})
  end

  def reverse_geocode(pid, params) do
    GenServer.call(pid, {:reverse_geocode, params[:latlng]})
  end

  def update(pid, location) do
    GenServer.call(pid, {:update, location})
  end

  def link(pid, from, to) do
    GenServer.cast(pid, {:link, from, to})
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  def init(args), do: {:ok, args}

  def start_link(opts \\ []) do
    {name, opts} = Keyword.pop(opts, :name, Config.default_store_name())
    GenServer.start_link(__MODULE__, {%{}, %{}, opts}, name: name)
  end

  # Fetch geocode
  def handle_call({:geocode, location}, _from, {links, store, _} = state) do
    key = encode(location)
    result = Maybe.wrap(links) |> fmap(&Map.get(&1, key)) |> fmap(&Map.get(store, &1))
    {:reply, result, state}
  end

  # Fetch reverse geocode
  def handle_call({:reverse_geocode, latlon}, _from, {_, store, opts} = state) do
    key = encode(latlon, opts[:precision])
    result = Maybe.wrap(store) |> fmap(&Map.get(&1, key))
    {:reply, result, state}
  end

  # Update store
  def handle_call({:update, coords}, _from, {links, store, opts}) do
    %{lat: lat, lon: lon} = coords

    location =
      coords.location
      |> Map.take(~w[city state country]a)
      |> Enum.filter(&is_binary(elem(&1, 1)))
      |> Enum.map_join("", &elem(&1, 1))

    key = encode({lat, lon}, opts[:precision])
    link = encode(location)

    state = {Map.put(links, link, key), Map.put(store, key, coords), opts}
    {:reply, coords, state}
  end

  # Get the state
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  # Link a query to a cached value
  def handle_cast({:link, from, %{lat: lat, lon: lon}}, {links, store, opts}) do
    key = encode({lat, lon}, opts[:precision])
    link = encode(from[:address] || from[:latlng], opts[:precision])
    {:noreply, {Map.put(links, link, key), store, opts}}
  end

  defp encode(location, opt \\ nil)

  defp encode({lat, lon}, precision) do
    Geohash.encode(:erlang.float(lat), :erlang.float(lon), precision)
  end

  defp encode(location, _) when is_binary(location) do
    location
    |> String.downcase()
    |> String.replace(~r/[^\w]/, "")
    |> String.trim()
    |> :base64.encode()
  end
end
