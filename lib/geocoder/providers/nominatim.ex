defmodule Geocoder.Providers.Nominatim do
  use HTTPoison.Base
  use Towel

  @endpoint "http://nominatim.openstreetmap.org/"

  def geocode(address) do
    request("search", q: address)
    |> fmap(fn [%{"lat" => lat, "lon" => lon}|_] ->
      [lat, lon]
      |> Enum.map(&elem(Float.parse(&1), 0))
      |> List.to_tuple
    end)
  end

  @reverse_geocode [
    types: ["city", "state", "country"]
  ]

  def reverse_geocode({lat,lon}, opts \\ []) do
    opts = Keyword.merge(@reverse_geocode, opts)

    request("reverse", lat: lat, lon: lon, zoom: 9)
    |> fmap(fn %{"address" => address} ->
      opts[:types]
      |> Enum.map(&Map.get(address, &1))
      |> List.to_tuple
    end)
  end

  @default_params %{
    format: "json",
    limit: 1
  }

  def request(path, params \\ []) do
    get(path, [], params: Enum.into(params, @default_params))
    |> fmap(&Map.get(&1, :body))
  end

  def process_url(url) do
    @endpoint <> url
  end

  def process_response_body(body) do
    body |> Poison.decode!
  end
end