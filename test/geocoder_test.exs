defmodule GeocoderTest do
  use ExUnit.Case

  test "An address in Belgium" do
    {:ok, coords} = Geocoder.call("Dikkelindestraat 46, 9032 Wondelgem, Belgium")
    %Geocoder.Coords{bounds: bounds, location: location, lat: lat, lon: lon} = coords

    assert bounds.bottom == 51.0773992
    assert bounds.left == 3.7073572
    assert bounds.right == 3.7073742
    assert bounds.top == 51.0774037
    assert location.street == "Dikkelindestraat"
    assert location.street_number == "46"
    assert location.city == "Gent"
    assert location.country == "Belgium"
    assert location.country_code == "BE"
    assert location.postal_code == "9032"
    assert location.formatted_address == "Dikkelindestraat 46, 9032 Gent, Belgium"
    assert lat == 51.0774037
    assert lon == 3.7073742
  end
end
