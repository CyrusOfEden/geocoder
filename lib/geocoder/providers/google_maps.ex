defmodule Geocoder.GoogleMaps do
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
    %Geocoder.GoogleMaps{
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
    %Geocoder.GoogleMaps{formatted_address: address}
  end

  def new(data) when is_map(data) do
    result = data[:results] || data["results"]
    case result do
      nil      -> one_from_map(data)
      # [one]    -> one_from_map(one)
      [_ | _]  -> result |> Enum.map(&one_from_map(&1))
    end
  end

  defp one_from_map(data) when is_map(data) do
    %Geocoder.GoogleMaps{} |> Map.merge(data |> atomize_keys)
  end

  ##############################################################################

  defimpl Geocoder.Data, for: Geocoder.GoogleMaps do
    def address(data) do
      data.formatted_address
    end

    # TODO: should we make use of "political" type?
    def components(data) do
      data.address_components
        |> Enum.reduce(%{}, fn %{long_name: long_name, short_name: short_name, types: [type | _]}, acc ->
                              acc = if short_name == long_name, do: acc, else: Map.put(acc, String.to_atom(type <> "_code"), short_name)
                              acc |> Map.put(String.to_atom(type), long_name)
                            end)
    end

    # %{administrative_area_level_1: "Vlaanderen",
    #   administrative_area_level_2: "Oost-Vlaanderen",
    #   country: "Belgium",
    #   locality: "Gent",
    #   postal_code: "9032",
    #   route: "Dikkelindestraat",
    #   street_number: "46"}
    def location(data) do
      comps = data |> components
      %Geocoder.Location{
        city: comps[:locality],
        state: comps[:county],
        country: comps[:country] || comps[:administrative_area_level_2] || comps[:administrative_area_level_1],
        postal_code: comps[:postal_code],
        street: comps[:route],
        street_number: comps[:street_number],
        country_code: comps[:country_code],
        formatted_address: address(data),
      }
    end

    def latlng(data) do
      case data.geometry.location do
        %{lat: nil} -> nil
        %{lon: nil} -> nil
        %{lng: nil} -> nil
        %{lat: lat, lng: lng} -> %Geocoder.Coords{lat: lat, lon: lng}
        %{lat: lat, lon: lon} -> %Geocoder.Coords{lat: lat, lon: lon}
        result -> result
      end
    end

    def place_id(data) do
      data.place_id
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
      data.types
    end

    def query(data) do
      %{
        address: address(data),
        components: components(data) |> Enum.map(fn {k, v} -> "#{k}:#{v}" end) |> Enum.join("|"),
        latlng: latlng(data),
        place_id: place_id(data),
        bounds: bounds(data),
        result_type: result_type(data) |> Enum.join("|")
      } |> Enum.reject(fn {_, v} ->
             case v do
               nil -> true
               []  -> true
               ""  -> true
               _   -> false
             end
           end)
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
