defmodule Geocoder.Providers.OpenStreetMaps do
  @moduledoc """
  OpenStreetMaps provider logic. Does not requires a key

  See documentation details at https://nominatim.org/release-docs/develop/api/Overview/
  """
  use Towel

  @behaviour Geocoder.Provider

  @endpoint "https://nominatim.openstreetmap.org"
  @endpath_reverse "/reverse"
  @endpath_search "/search"
  @defaults [format: "json", "accept-language": "en", addressdetails: 1]
  @map %{
    "house_number" => :street_number,
    # Australia suburbs are used instead of counties: https://github.com/knrz/geocoder/pull/71
    "suburb" => :county,
    "county" => :county,
    "city" => :city,
    "road" => :street,
    "state" => :state,
    "postcode" => :postal_code,
    "country" => :country
  }

  def geocode(payload_opts, opts \\ []) do
    request(@endpath_search, extract_payload_opts(payload_opts), opts)
    |> fmap(&parse_geocode/1)
  end

  def geocode_list(payload_opts, opts \\ []) do
    request_all(@endpath_search, extract_payload_opts(payload_opts), opts)
    |> fmap(fn
      %{} = result -> [parse_geocode(result)]
      r when is_list(r) -> Enum.map(r, &parse_geocode/1)
    end)
  end

  def reverse_geocode(payload_opts, opts \\ []) do
    request(@endpath_reverse, extract_payload_opts(payload_opts), opts)
    |> fmap(&parse_reverse_geocode/1)
  end

  def reverse_geocode_list(payload_opts, opts \\ []) do
    request_all(@endpath_search, extract_payload_opts(payload_opts), opts)
    |> fmap(fn
      %{} = result -> [parse_reverse_geocode(result)]
      r when is_list(r) -> Enum.map(r, &parse_reverse_geocode/1)
    end)
  end

  defp request(path, params, opts) do
    request_all(path, params, opts)
    |> fmap(&List.first/1)
  end

  defp extract_payload_opts(opts) do
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
    [lat, lon] = [lat, lon] |> Enum.map(&elem(Float.parse(&1), 0))
    %Geocoder.Coords{lat: lat, lon: lon}
  end

  defp geocode_coords(_), do: %Geocoder.Coords{}

  defp geocode_bounds(%{"boundingbox" => bbox}) do
    [north, south, west, east] = bbox |> Enum.map(&elem(Float.parse(&1), 0))
    %Geocoder.Bounds{top: north, right: east, bottom: south, left: west}
  end

  defp geocode_bounds(_), do: %Geocoder.Bounds{}

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

  defp request_all(path, params, opts) do
    request = %{
      method: :get,
      url: @endpoint <> path,
      query_params: Enum.into(params, %{})
    }

    case Geocoder.Request.request(request, opts) do
      {:ok, %{status_code: 200, body: results}} ->
        {:ok, List.wrap(results)}

      {_, response} ->
        {:error, response}
    end
  end
end
