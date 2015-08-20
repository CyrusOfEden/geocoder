defmodule Geocoder.Providers.Maps do
  use HTTPoison.Base
  use Towel

  @endpoint "https://maps.googleapis.com/"

  def geocode(address) do
    extract = fn %{"lat" => lat, "lng" => lng} ->
      {lat, lng}
    end

    request("maps/api/geocode/json", address: address)
    |> fmap(&Map.get(&1, "geometry"))
    |> fmap(&Map.get(&1, "location"))
    |> fmap(extract)
  end

  @reverse_geocode [
    types: ["locality", "administrative_area_level_1"],
    param: "short_name",
    extract: nil
  ]

  def reverse_geocode({lat,lng}, opts \\ []) do
    opts = Keyword.merge(@reverse_geocode, opts)

    params = %{
      "latlng" => "#{lat},#{lng}",
      "types[]" => Enum.join(opts[:types], ",")
    }

    filter = fn component ->
      Enum.find(opts[:types], &Enum.member?(Map.get(component, "types"), &1))
    end

    extract = opts[:extract] || &Map.get(&1, opts[:param])

    request("maps/api/geocode/json", params)
    |> fmap(&Map.get(&1, "address_components"))
    |> fmap(&Enum.filter_map(&1, filter, extract))
    |> fmap(&List.to_tuple/1)
  end

  def request(path, params) do
    get(path, [], params: Enum.into(params, %{}))
    |> fmap(&Map.get(&1, :body))
    |> fmap(&Map.get(&1, "results"))
    |> fmap(&List.first/1)
  end

  def process_url(url) do
    @endpoint <> url
  end

  def process_response_body(body) do
    body |> Poison.decode!
  end
end