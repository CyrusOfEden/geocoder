defmodule Geocoder.Providers.GoogleMaps do
  use HTTPoison.Base
  use Towel

  @endpoint "https://maps.googleapis.com/"

  def geocode(opts) do
    request("maps/api/geocode/json", extract_opts(opts))
    |> fmap(&parse_geocode/1)
  end

  def geocode_list(opts) do
    request_all("maps/api/geocode/json", extract_opts(opts))
    |> fmap(fn r -> Enum.map(r, &parse_geocode/1) end)
  end

  def reverse_geocode(opts) do
    request("maps/api/geocode/json", extract_opts(opts))
    |> fmap(&parse_reverse_geocode/1)
  end

  def reverse_geocode_list(opts) do
    request_all("maps/api/geocode/json", extract_opts(opts))
    |> fmap(fn r -> Enum.map(r, &parse_reverse_geocode/1) end)
  end

  defp extract_opts(opts) do
    opts
    |> Keyword.take([
      :key,
      :address,
      :components,
      :bounds,
      :language,
      :region,
      :latlng,
      :placeid,
      :result_type,
      :location_type
    ])
    |> Keyword.update(:latlng, nil, fn
      {lat, lng} -> "#{lat},#{lng}"
      q -> q
    end)
    |> Keyword.delete(:latlng, nil)
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
    %{
      "northeast" => %{"lat" => north, "lng" => east},
      "southwest" => %{"lat" => south, "lng" => west}
    } = bounds

    %Geocoder.Bounds{top: north, right: east, bottom: south, left: west}
  end

  defp geocode_bounds(_), do: %Geocoder.Bounds{}

  @components [
    "locality",
    "administrative_area_level_1",
    "administrative_area_level_2",
    "country",
    "postal_code",
    "street",
    "street_number",
    "route"
  ]
  @map %{
    "street_number" => :street_number,
    "route" => :street,
    "street_address" => :street,
    "locality" => :city,
    "administrative_area_level_1" => :state,
    "administrative_area_level_2" => :county,
    "postal_code" => :postal_code,
    "country" => :country
  }
  defp geocode_location(%{
         "address_components" => components,
         "formatted_address" => formatted_address
       }) do
    name = &Map.get(&1, "long_name")

    type = fn component ->
      component |> Map.get("types") |> Enum.find(&Enum.member?(@components, &1))
    end

    map = &{type.(&1), name.(&1)}

    reduce = fn {type, name}, location ->
      struct(location, [{@map[type], name}])
    end

    country =
      Enum.find(components, fn component ->
        component |> Map.get("types") |> Enum.member?("country")
      end)

    country_code =
      case country do
        nil ->
          nil

        %{"short_name" => name} ->
          name
      end

    location = %Geocoder.Location{
      country_code: country_code,
      formatted_address: formatted_address
    }

    components
    |> Enum.filter(type)
    |> Enum.map(map)
    |> Enum.reduce(location, reduce)
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
