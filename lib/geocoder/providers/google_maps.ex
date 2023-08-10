defmodule Geocoder.Providers.GoogleMaps do
  @moduledoc """
  Google Map provider logic. Google requires a key

  See documentation details at https://developers.google.com/maps/documentation/geocoding/
  """
  use Towel

  @behaviour Geocoder.Provider

  @endpoint "https://maps.googleapis.com/"
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
  def geocode(payload_opts, opts \\ []) do
    request("maps/api/geocode/json", extract_payload_opts(payload_opts), opts)
    |> fmap(&parse_geocode/1)
  end

  def geocode_list(payload_opts, opts \\ []) do
    request_all("maps/api/geocode/json", extract_payload_opts(payload_opts), opts)
    |> fmap(fn r -> Enum.map(r, &parse_geocode/1) end)
  end

  def reverse_geocode(payload_opts, opts \\ []) do
    request("maps/api/geocode/json", extract_payload_opts(payload_opts), opts)
    |> fmap(&parse_reverse_geocode/1)
  end

  def reverse_geocode_list(payload_opts, opts \\ []) do
    request_all("maps/api/geocode/json", extract_payload_opts(payload_opts), opts)
    |> fmap(fn r -> Enum.map(r, &parse_reverse_geocode/1) end)
  end

  defp request(path, params, opts) do
    request_all(path, params, opts)
    |> fmap(&List.first/1)
  end

  defp extract_payload_opts(opts) do
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
  end

  defp parse_geocode(response) do
    coords = geocode_coords(response)
    bounds = geocode_bounds(response)
    location = geocode_location(response)
    partial_match = response["partial_match"]
    %{coords | bounds: bounds, location: location, partial_match: partial_match}
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

  defp request_all(path, params, opts) do
    params = Keyword.merge(params, key: opts[:key])

    request = %{
      method: :get,
      url: @endpoint <> path,
      query_params: Enum.into(params, %{})
    }

    case Geocoder.Request.request(request, opts) do
      {:ok,
       %{
         status_code: 200,
         body: %{"results" => [], "error_message" => error_message, "status" => _status}
       }} ->
        {:error, error_message}

      {:ok, %{status_code: 200, body: %{"status" => "OK", "results" => results}}} ->
        {:ok, List.wrap(results)}

      {_, response} ->
        {:error, response}
    end
  end
end
