defmodule Geocoder.Providers.OpenCageData do
  @moduledoc """
  Open Cage Data provider logic. Open Cage Data requires a key

  See documentation details at https://opencagedata.com/api
  """
  use Towel

  @behaviour Geocoder.Provider

  @endpoint "http://api.opencagedata.com/"
  @path "geocode/v1/json"
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
  def geocode(payload_opts, opts \\ []) do
    request(@path, extract_payload_opts(payload_opts), opts)
    |> fmap(&parse_geocode/1)
  end

  def geocode_list(payload_opts, opts \\ []) do
    request_all(@path, extract_payload_opts(payload_opts), opts)
    |> fmap(fn r -> Enum.map(r, &parse_geocode/1) end)
  end

  def reverse_geocode(payload_opts, opts \\ []) do
    request(@path, extract_payload_opts(payload_opts), opts)
    |> fmap(&parse_reverse_geocode/1)
  end

  def reverse_geocode_list(payload_opts, opts \\ []) do
    request_all(@path, extract_payload_opts(payload_opts), opts)
    |> fmap(fn r -> Enum.map(r, &parse_reverse_geocode/1) end)
  end

  defp request(path, params, opts) do
    request_all(path, params, opts)
    |> fmap(&List.first/1)
  end

  defp extract_payload_opts(opts) do
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

  defp geocode_location(%{"components" => components, "formatted" => formatted_address}) do
    reduce = fn {type, name}, location ->
      struct(location, [{@map[type], name}])
    end

    location = %Geocoder.Location{formatted_address: formatted_address}

    components
    |> Enum.reduce(location, reduce)
    |> Map.drop([nil])
  end

  defp request_all(path, params, opts) do
    params = Keyword.merge(params, key: opts[:key])

    request = %{
      method: :get,
      url: @endpoint <> path,
      query_params: Enum.into(params, %{})
    }

    case Geocoder.Request.request(request, opts) do
      {:ok, %{status_code: 401, body: %{"status" => %{"message" => message}}}} ->
        {:error, message}

      {:ok, %{status_code: 200, body: %{"results" => results}}} ->
        {:ok, List.wrap(results)}

      {_, response} ->
        {:error, response}
    end
  end
end
