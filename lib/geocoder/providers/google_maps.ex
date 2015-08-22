defmodule Geocoder.Providers.GoogleMaps do
  use HTTPoison.Base
  use Towel

  @endpoint "https://maps.googleapis.com/"

  def geocode(address) when is_binary(address) do
    request("maps/api/geocode/json", address: address)
    |> fmap(&parse_geocode/1)
  end

  def reverse_geocode(%{lat: lat, lon: lon}) do
    reverse_geocode({lat,lon})
  end
  def reverse_geocode({lat,lon}) do
    request("maps/api/geocode/json", [{"latlng", "#{lat},#{lon}"}])
    |> fmap(&parse_reverse_geocode/1)
  end

  defp parse_geocode(response) do
    coords = geocode_coords(response)
    bounds = geocode_bounds(response)
    location = geocode_location(response)
    %{coords | bounds: bounds, location: location}
  end

  defp parse_reverse_geocode(response) do
    coords = geocode_coords(response)
    location = geocode_location(response)
    %{coords | location: location}
  end

  defp geocode_coords(%{"geometry" => %{"location" => coords}}) do
    %{"lat" => lat, "lng" => lon} = coords
    %Geocoder.Coords{lat: lat, lon: lon}
  end

  defp geocode_bounds(%{"geometry" => %{"bounds" => bounds}}) do
    %{"northeast" => %{"lat" => north, "lng" => east},
      "southwest" => %{"lat" => south, "lng" => west}} = bounds
    %Geocoder.Bounds{top: north, right: east, bottom: south, left: west}
  end

  @components ["locality", "administrative_area_level_1", "country"]
  defp geocode_location(%{"address_components" => components}) do
    filter = fn component ->
      types = Map.get(component, "types")
      Enum.any?(types, &Enum.member?(@components, &1))
    end

    map = &Map.get(&1, "long_name")

    case Enum.filter_map(components, filter, map) do
      [country] ->
        %Geocoder.Location{country: country}
      [city,country] ->
        %Geocoder.Location{city: city, country: country}
      [city,state,country] ->
        %Geocoder.Location{city: city, state: state, country: country}
    end
  end

  defp request(path, params) do
    get(path, [], params: Enum.into(params, %{}))
    |> fmap(&Map.get(&1, :body))
    |> fmap(&Map.get(&1, "results"))
    |> fmap(&List.first/1)
  end

  defp process_url(url) do
    @endpoint <> url
  end

  defp process_response_body(body) do
    body |> Poison.decode!
  end
end