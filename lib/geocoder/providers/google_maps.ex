require IEx

defmodule Geocoder.Providers.GoogleMaps do
  use HTTPoison.Base
  use Towel

  @doc """
      {
         "results" : [
            {
               "address_components" : [
                  {
                     "long_name" : "1600",
                     "short_name" : "1600",
                     "types" : [ "street_number" ]
                  },
                  {
                     "long_name" : "Amphitheatre Pkwy",
                     "short_name" : "Amphitheatre Pkwy",
                     "types" : [ "route" ]
                  },
                  {
                     "long_name" : "Mountain View",
                     "short_name" : "Mountain View",
                     "types" : [ "locality", "political" ]
                  },
                  {
                     "long_name" : "Santa Clara County",
                     "short_name" : "Santa Clara County",
                     "types" : [ "administrative_area_level_2", "political" ]
                  },
                  {
                     "long_name" : "California",
                     "short_name" : "CA",
                     "types" : [ "administrative_area_level_1", "political" ]
                  },
                  {
                     "long_name" : "United States",
                     "short_name" : "US",
                     "types" : [ "country", "political" ]
                  },
                  {
                     "long_name" : "94043",
                     "short_name" : "94043",
                     "types" : [ "postal_code" ]
                  }
               ],
               "formatted_address" : "1600 Amphitheatre Parkway, Mountain View, CA 94043, USA",
               "geometry" : {
                  "location" : {
                     "lat" : 37.4224764,
                     "lng" : -122.0842499
                  },
                  "location_type" : "ROOFTOP",
                  "viewport" : {
                     "northeast" : {
                        "lat" : 37.4238253802915,
                        "lng" : -122.0829009197085
                     },
                     "southwest" : {
                        "lat" : 37.4211274197085,
                        "lng" : -122.0855988802915
                     }
                  }
               },
               "place_id" : "ChIJ2eUgeAK6j4ARbn5u_wAGqWA",
               "types" : [ "street_address" ]
            }
         ],
         "status" : "OK"
      }
  """
  defstruct address_components: [],
            formatted_address: nil,
            geometry: %{
              location: %{lat: nil, lng: nil},
              location_type: nil,
              viewport: %{
                northeast: %{lat: nil, lng: nil},
                southwest: %{lat: nil, lng: nil}
              }
            },
            place_id: nil,
            types: []

  ##############################################################################

  def new({lat, lng}) do
    %Geocoder.Providers.GoogleMaps{
      geometry: %{
        location: %{lat: lat, lng: lng},
        location_type: nil,
        viewport: %{
          northeast: %{lat: nil, lng: nil},
          southwest: %{lat: nil, lng: nil}
        }
      }
    }
  end

  def new(address) when is_binary(address) do
    %Geocoder.Providers.GoogleMaps{formatted_address: address}
  end

  def new(data) when is_map(data) do
    %Geocoder.Providers.GoogleMaps{} |> Map.merge(data |> atomize_keys)
  end

  ##############################################################################

  defimpl Geocoder.Data, for: Geocoder.Providers.GoogleMaps do
    def address(data) do
      case data.formatted_address do
        "" -> nil
        result -> result
      end
    end

    # TODO: should we make use of "political" type?
    def components(data) do
      result = data.address_components |> Enum.reduce(%{},
        fn %{long_name: long_name, short_name: _short_name, types: [type | _]}, acc ->
          acc |> Map.put(type |> String.to_atom, long_name) # TODO: should we make use of "short_name"?
        end)

      if result |> Enum.empty?, do: nil, else: result
    end

    def latlng(data) do
      case data.geometry.location do
        %{lat: nil, lng: _} -> nil
        %{lat: nil, lon: _} -> nil
        %{lat: _, lng: nil} -> nil
        %{lat: _, lon: nil} -> nil
        %{lat: lat, lng: lng} -> %Geocoder.Coords{lat: lat, lon: lng}
        %{lat: lat, lon: lon} -> %Geocoder.Coords{lat: lat, lon: lon}
        result -> result
      end
    end

    def place_id(data) do
      case data.place_id do
        "" -> nil
        result -> result
      end
    end

    def bounds(data) do
      %{northeast: %{lat: north, lng: east},
        southwest: %{lat: south, lng: west}} = data.geometry.viewport
      if north == nil or east == nil or south == nil or west == nil do
        nil
      else
        %Geocoder.Bounds{top: north, right: east, bottom: south, left: west}
      end
    end

    def result_type(data) do
      case data.types do
        [] -> nil
        result -> result
      end
    end

    def query(data) do
      acc = %{}

      unless (d = address(data)) == nil, do: acc = acc |> put_in([:address], d)
      unless (d = components(data)) == nil do
        d = d |> Enum.map(fn {k, v} -> "#{k}:#{v}" end) |> Enum.join("|")
        acc = acc |> put_in([:components], d)
      end
      unless (d = latlng(data)) == nil, do: acc = acc |> put_in([:latlng], "#{d}")
      unless (d = place_id(data)) == nil, do: acc = acc |> put_in([:place_id], d)
      unless (d = bounds(data)) == nil, do: acc = acc |> put_in([:bounds], "#{d}")
      if is_list(d = result_type(data)), do: acc = acc |> put_in([:address], d |> Enum.join("|"))

      acc |> Map.to_list
    end

    def endpoint(_, _) do
      "https://maps.googleapis.com/maps/api/geocode/json"
    end
  end

  ##############################################################################

  defp atomize_keys(map) when is_map(map) do
    for {k, v} <- map, into: %{} do
      {String.to_atom(k), atomize_keys(v)}
    end
  end
  defp atomize_keys(list) when is_list(list) do
    list |> Enum.map(&atomize_keys(&1))
  end
  defp atomize_keys(val), do: val

end
