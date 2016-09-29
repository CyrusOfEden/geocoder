defmodule Geocoder.OpenStreetMaps do

  @doc """
      {
        "address": {
            "city": "Berlin",
            "city_district": "Mitte",
            "construction": "Unter den Linden",
            "continent": "European Union",
            "country": "Deutschland",
            "country_code": "de",
            "house_number": "1",
            "neighbourhood": "Scheunenviertel",
            "postcode": "10117",
            "public_building": "Kommandantenhaus",
            "state": "Berlin",
            "suburb": "Mitte"
        },
        "boundingbox": [
            "52.5170783996582",
            "52.5173187255859",
            "13.3975105285645",
            "13.3981599807739"
        ],
        "class": "amenity",
        "display_name": "Kommandantenhaus, 1, Unter den Linden, Scheunenviertel, Mitte, Berlin, 10117, Deutschland, European Union",
        "importance": 0.73606775332943,
        "lat": "52.51719785",
        "licence": "Data \u00a9 OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright",
        "lon": "13.3978352028938",
        "osm_id": "15976890",
        "osm_type": "way",
        "place_id": "30848715",
        "svg": "M 13.397511 -52.517283599999999 L 13.397829400000001 -52.517299800000004 13.398131599999999 -52.517315099999998 13.398159400000001 -52.517112099999999 13.3975388 -52.517080700000001 Z",
        "type": "public_building"
      }
  """

  # url="https://nominatim.openstreetmap.org/reverse?format=json&accept-language={{ language }}&lat={{ latitude }}&lon={{ longitude }}&zoom={{ zoom }}&addressdetails=1"

  defstruct address: %{
              continent: nil,
              country: nil,
              country_code: nil,
              state: nil,
              suburb: nil,
              city: nil,
              city_district: nil,
              construction: nil, # or road
              road: nil, # or construction
              postcode: nil,
              neighbourhood: nil,
              public_building: nil,
              house_number: nil
            },
            display_name: nil,
            lat: nil,
            lon: nil,
            place_id: nil,
            license: nil,
            osm_type: nil,
            type: nil,
            class: nil,
            importance: nil,
            svg: nil,
            osm_id: nil,
            boundingbox: nil


  ##############################################################################

  def new({lat, lon}) do
    %Geocoder.OpenStreetMaps{lat: lat, lon: lon}
  end

  def new(address) when is_binary(address) do
    %Geocoder.OpenStreetMaps{display_name: address}
  end

  def new(data) when is_map(data) do
    %Geocoder.OpenStreetMaps{} |> Map.merge(data |> Geocoder.Provider.atomize_keys)
  end

  def new(data) when is_list(data) do
    data |> Enum.map(&new(&1))
  end

  ##############################################################################

  defimpl Geocoder.Data, for: Geocoder.OpenStreetMaps do
    @defaults %{format: "json", "accept-language": "en", addressdetails: 1}

    def address(data) do
      data.display_name
    end

    def components(data) do
      data.address
    end

    # %{
    #   "road": "Dikkelindestraat",
    #   "city_district": "Wondelgem",
    #   "city": "Ghent",
    #   "county": "Gent",
    #   "state": "Flanders",
    #   "postcode": "9032",
    #   "country": "Belgium",
    #   "country_code": "be"}
    def location(data) do
      comps = data |> components
      %Geocoder.Location{
        city: comps[:city],
        state: comps[:state],
        country: comps[:country],
        postal_code: comps[:postcode],
        street: comps[:road] || comps[:construction],
        street_number: comps[:house_number] || comps[:public_building],
        country_code: (if comps[:country_code], do: comps[:country_code] |> String.upcase, else: nil),
        formatted_address: data |> address
      }
    end

    def latlng(data) do
      case {data.lat, data.lon} do
        {nil, _} -> nil
        {_, nil} -> nil
        {lat, lon} -> %Geocoder.Coords{lat: lat |> to_string |> String.to_float, lon: lon |> to_string |> String.to_float}
      end
    end

    def place_id(data) do
      data.place_id
    end

    def bounds(data) do
      case data.boundingbox do
        [south, north, east, west] ->
          %Geocoder.Bounds{
            top: north |> String.to_float,
            right: east |> String.to_float,
            bottom: south |> String.to_float,
            left: west |> String.to_float}
        _ -> nil
      end
    end

    def result_type(data) do
      data.type || data.osm_type
    end

    def query(data, type) do
      @defaults |> Map.merge(case type do
                               :direct  -> %{q: address(data)}
                               :reverse ->
                                  case data |> latlng do
                                    nil -> %{}
                                    %Geocoder.Coords{lat: lat, lon: lon}   -> %{lat: lat, lon: lon}
                                  end
                             end)
    end

    def endpoint(_, type) do
      "http://nominatim.openstreetmap.org" <> case type do
                                                :direct  -> "/search"
                                                :reverse -> "/reverse"
                                              end
    end
  end

end
