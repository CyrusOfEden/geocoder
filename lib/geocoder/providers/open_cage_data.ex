defmodule Geocoder.Providers.OpenCageData do
  use HTTPoison.Base
  use Towel

  @endpoint "http://api.opencagedata.com/"
  @path "geocode/v1/json"

  def geocode(opts) do
    request(@path, opts |> extract_opts())
    |> fmap(&parse_geocode/1)
  end

  def geocode_list(opts) do
    request_all(@path, opts |> extract_opts())
    |> fmap(fn r -> Enum.map(r, &parse_geocode/1) end)
  end

  def reverse_geocode(opts) do
    request(@path, opts |> extract_opts())
    |> fmap(&parse_reverse_geocode/1)
  end

  def reverse_geocode_list(opts) do
    request_all(@path, opts |> extract_opts())
    |> fmap(fn r -> Enum.map(r, &parse_reverse_geocode/1) end)
  end

  defp extract_opts(opts) do
    opts
    |> Keyword.merge(opts)
    |> Keyword.put(
      :q,
      case opts |> Keyword.take([:address, :latlng]) |> Keyword.values() do
        [{lat, lon}] -> "#{lat},#{lon}"
        [query] -> query
        _ -> nil
      end
    )
    |> Keyword.take([
      :q,
      :key,
      :bounds,
      :language,
      :add_request,
      :countrycode,
      :jsonp,
      :limit,
      :min_confidence,
      :no_annotations,
      :no_dedupe,
      :pretty
    ])
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

  defp geocode_coords(%{"geometry" => coords}) do
    %{"lat" => lat, "lng" => lon} = coords
    %Geocoder.Coords{lat: lat, lon: lon}
  end

  defp geocode_bounds(%{"bounds" => bounds}) do
    %{
      "northeast" => %{"lat" => north, "lng" => east},
      "southwest" => %{"lat" => south, "lng" => west}
    } = bounds

    %Geocoder.Bounds{top: north, right: east, bottom: south, left: west}
  end

  defp geocode_bounds(_), do: %Geocoder.Bounds{}

  @map %{
    "house_number" => :street_number,
    "road" => :street,
    "city" => :city,
    "state" => :state,
    "county" => :county,
    "postcode" => :postal_code,
    "country" => :country,
    "country_code" => :country_code
  }
  defp geocode_location(%{"components" => components, "formatted" => formatted_address}) do
    reduce = fn {type, name}, location ->
      struct(location, [{@map[type], name}])
    end

    location = %Geocoder.Location{formatted_address: formatted_address}

    components
    |> Enum.reduce(location, reduce)
    |> Map.drop([nil])
  end

  defp request_all(path, params) do
    httpoison_options = Application.get_env(:geocoder, Geocoder.Worker)[:httpoison_options] || []

    case get(path, [], Keyword.merge(httpoison_options, params: Enum.into(params, %{}))) do
      {:ok, %{status_code: 200, body: %{"results" => results}}} ->
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
