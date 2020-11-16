defmodule GeocoderTest do
  use ExUnit.Case

  setup do
    # there's some state we need to clear before each test run
    # https://github.com/sasa1977/con_cache/issues/11#issuecomment-116806567
    :ok = Supervisor.terminate_child(Geocoder.Supervisor, Geocoder.Store)
    {:ok, _} = Supervisor.restart_child(Geocoder.Supervisor, Geocoder.Store)

    # OpenStreetData is rate-limited at 1rps. Let's ensure our tests don't break that rate limit.
    Process.sleep(1_000)

    :ok
  end

  test "An address in New York" do
    {:ok, coords} = Geocoder.call("1991 15th Street, Troy, NY 12180")
    assert_new_york(coords)
  end

  test "An address in Belgium" do
    {:ok, coords} = Geocoder.call("Dikkelindestraat 46, 9032 Wondelgem, Belgium")
    assert_belgium(coords)
  end

  test "properly handles call-specific provider and key configurations" do
    {:error, "missing API key"} =
      Geocoder.call("1991 15th Street, Troy, NY 12180", provider: Geocoder.Providers.OpenCageData)

    {
      :error,
      "invalid API key"
    } =
      Geocoder.call("1991 15th Street, Troy, NY 12180",
        provider: Geocoder.Providers.OpenCageData,
        key: "bad_key"
      )
  end

  test "Reverse geocode" do
    {:ok, coords} = Geocoder.call({51.0775264, 3.7073382})
    assert_belgium(coords)
  end

  test "A list of results for an address in Belgium" do
    {:ok, coords} = Geocoder.call_list("Dikkelindestraat 46, 9032 Wondelgem, Belgium")
    assert is_list(coords)
    assert Enum.count(coords) > 0
    assert_belgium(coords |> List.first())
  end

  test "A list of results for coordinates" do
    {:ok, coords} = Geocoder.call_list({51.0775264, 3.7073382})
    assert is_list(coords)
    assert Enum.count(coords) > 0
  end

  defp assert_new_york(%Geocoder.Coords{location: location}) do
    assert location.street_number == "1991"
    assert location.street == "15th Street"
    assert String.contains?(location.city, "Troy")
    assert location.county == "Rensselaer County"
    assert location.country_code |> String.upcase() == "US"
    assert location.postal_code == "12180"
  end

  defp assert_belgium(%{bounds: bounds, location: location, lat: lat, lon: lon}) do
    # Bounds are not always returned
    assert nil == bounds.bottom || bounds.bottom |> Float.round(2) == 51.08
    assert nil == bounds.left || bounds.left |> Float.round(2) == 3.71
    assert nil == bounds.right || bounds.right |> Float.round(2) == 3.71
    assert nil == bounds.top || bounds.top |> Float.round(2) == 51.08

    assert nil == location.street_number || location.street_number == "46"
    assert location.street == "Dikkelindestraat"
    assert location.city == "Gent" || location.city == "Ghent"
    assert location.country == "Belgium"
    assert location.country_code |> String.upcase() == "BE"
    assert location.postal_code == "9032"
    # lhs:  "Dikkelindestraat, Wondelgem, Ghent, Gent, East Flanders, Flanders, 9032, Belgium"
    # rhs:  "Dikkelindestraat 46, 9032 Gent, Belgium"
    assert location.formatted_address |> String.match?(~r/Dikkelindestraat/)

    assert location.formatted_address |> String.match?(~r/Gent/) ||
             location.formatted_address |> String.match?(~r/Ghent/)

    assert location.formatted_address |> String.match?(~r/9032/)
    assert location.formatted_address |> String.match?(~r/Belgium/)
    assert lat |> Float.round(2) == 51.08
    assert lon |> Float.round(2) == 3.71
  end
end
