defmodule GeocoderTest do
  use ExUnit.Case

  test "An address in Belgium" do
    {:ok, coords} = Geocoder.call("Dikkelindestraat 46, 9032 Wondelgem, Belgium")
    assert_belgium coords
  end

  test "Reverse geocode" do
    {:ok, coords} = Geocoder.call({51.0775264, 3.7073382})
    assert_belgium coords
  end

  test "A list of results for an address in Belgium" do
    {:ok, coords} = Geocoder.call_list("Dikkelindestraat 46, 9032 Wondelgem, Belgium")
    assert is_list(coords)
    assert 1 = Enum.count(coords)
    assert_belgium(coords |> List.first)
  end

  test "A list of results for coordinates" do
    {:ok, coords} = Geocoder.call_list({51.0775264, 3.7073382})
    assert is_list(coords)
    assert Enum.count(coords) > 0
  end
  
  defp assert_belgium(coords) do
    %Geocoder.Coords{bounds: _bounds, location: location, lat: lat, lon: lon} = coords
    # Bounds are not always returned
    # assert bounds.bottom == 51.0773992
    # assert bounds.left == 3.7073572
    # assert bounds.right == 3.7073742
    # assert bounds.top == 51.0774037
    assert location.street == "Dikkelindestraat"
    assert location.street_number == "46"
    assert location.city == "Gent"
    assert location.country == "Belgium"
    assert location.country_code == "BE"
    assert location.postal_code == "9032"
    assert location.formatted_address == "Dikkelindestraat 46, 9032 Gent, Belgium"
    assert lat == 51.0775264
    assert lon == 3.7073382
  end

end
