defmodule Geocoder.Providers.OpenStreetMaps do
  use HTTPoison.Base
  use Towel

  @endpoint "https://nominatim.openstreetmap.org/"
  @endpath_reverse "/reverse"
  @endpath_search "/search"
  @defaults [format: "json", "accept-language": "en", addressdetails: 1]

  def geocode(opts) do
    request(@endpath_search, extract_opts(opts))
    |> fmap(&parse_geocode/1)
  end

  def geocode_list(opts) do
    request_all(@endpath_search, extract_opts(opts))
    |> fmap(fn
      %{} = result -> [parse_geocode(result)]
      r when is_list(r) -> Enum.map(r, &parse_geocode/1)
    end)
  end

  def reverse_geocode(opts) do
    request(@endpath_reverse, extract_opts(opts))
    |> fmap(&parse_reverse_geocode/1)
  end

  def reverse_geocode_list(opts) do
    request_all(@endpath_search, extract_opts(opts))
    |> fmap(fn
      %{} = result -> [parse_reverse_geocode(result)]
      r when is_list(r) -> Enum.map(r, &parse_reverse_geocode/1)
    end)
  end

  defp extract_opts(opts) do
    @defaults
    |> Keyword.merge(opts)
    |> Keyword.update!(:"accept-language", fn default -> opts[:language] || default end)
    |> Keyword.put(
      :q,
      case opts |> Keyword.take([:address, :latlng]) |> Keyword.values() do
        [{lat, lon}] -> "#{lat},#{lon}"
        [query] -> query
        _ -> nil
      end
    )
    |> Keyword.take(
      [
        :q,
        :key,
        :address,
        :components,
        :bounds,
        :region,
        :latlon,
        :lat,
        :lon,
        :placeid,
        :result_type,
        :location_type
      ] ++ Keyword.keys(@defaults)
    )
  end

  defp parse_geocode([]), do: :error

  defp parse_geocode(response) do
    coords = geocode_coords(response)
    bounds = geocode_bounds(response)
    location = geocode_location(response)
    %{coords | bounds: bounds, location: location}
  end

  defp parse_reverse_geocode([]), do: :error

  defp parse_reverse_geocode(response) do
    coords = geocode_coords(response)
    bounds = geocode_bounds(response)
    location = geocode_location(response)
    %{coords | bounds: bounds, location: location}
  end

  defp geocode_coords(%{"lat" => lat, "lon" => lon}) do
    [lat, lon] = [lat, lon] |> Enum.map(&String.to_float(&1))
    %Geocoder.Coords{lat: lat, lon: lon}
  end

  defp geocode_coords(_), do: %Geocoder.Coords{}

  defp geocode_bounds(%{"boundingbox" => bbox}) do
    [north, south, west, east] = bbox |> Enum.map(&String.to_float(&1))
    %Geocoder.Bounds{top: north, right: east, bottom: south, left: west}
  end

  defp geocode_bounds(_), do: %Geocoder.Bounds{}

  # %{"address" =>
  #      %{"city" => "Ghent", "city_district" => "Wondelgem", "country" => "Belgium",
  #        "country_code" => "be", "county" => "Gent", "postcode" => "9032",
  #        "road" => "Dikkelindestraat", "state" => "Flanders"},
  #   "boundingbox" => ["51.075731", "51.0786674", "3.7063849", "3.7083991"],
  #   "display_name" => "Dikkelindestraat, Wondelgem, Ghent, Gent, East Flanders, Flanders, 9032, Belgium",
  #   "lat" => "51.0772661",
  #   "licence" => "Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright",
  #   "lon" => "3.7074267",
  #   "osm_id" => "45352282", "osm_type" => "way", "place_id" => "70350383"}
  @components ~W[city city_district country country_code county postcode road state]
  @map %{
    "house_number" => :street_number,
    "county" => :county,
    "city" => :city,
    "road" => :street,
    "state" => :state,
    "postcode" => :postal_code,
    "country" => :country
  }
  defp geocode_location(
         %{
           "address" => address
         } = response
       ) do
    reduce = fn {type, name}, location ->
      struct(location, [{@map[type], name}])
    end

    location = %Geocoder.Location{
      country_code: address["country_code"],
      formatted_address: response["display_name"]
    }

    address
    |> Enum.reduce(location, reduce)
  end

  defp request_all(path, params) do
    httpoison_options = Application.get_env(:geocoder, Geocoder.Worker)[:httpoison_options] || []

    case get(path, [], Keyword.merge(httpoison_options, params: Enum.into(params, %{}))) do
      {:ok, %{status_code: 200, body: results}} ->
        {:ok, List.wrap(results)}

      {_, response} ->
        {:error, response}
    end
  end

  def request(path, params) do
    request_all(path, params)
    |> fmap(&List.first/1)
  end

  def process_url(url) do
    @endpoint <> url
  end

  def process_response_body(body) do
    body |> Poison.decode!()
  end
end
