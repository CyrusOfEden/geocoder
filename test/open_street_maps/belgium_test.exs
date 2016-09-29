defmodule Geocoder.OpenStreetMaps.Test do
  use ExUnit.Case

  test "An address in Belgium" do
    {:ok, coords} = Geocoder.call("Dikkelindestraat 46, 9032 Wondelgem, Belgium", provider: Geocoder.OpenStreetMaps)
    assert_belgium coords
  end

  test "Reverse geocode" do
    {:ok, coords} = Geocoder.call({51.0775264, 3.7073382}, provider: Geocoder.OpenStreetMaps)
    assert_belgium coords
  end

  test "A list of results for an address in Belgium" do
    {:ok, coords} = Geocoder.call_list("Dikkelindestraat 46, 9032 Wondelgem, Belgium", provider: Geocoder.OpenStreetMaps)
    assert_belgium_list(coords, true)
  end

  test "A list of results for coordinates" do
    {:ok, coords} = Geocoder.call_list({51.0775264, 3.7073382}, provider: Geocoder.OpenStreetMaps)
    assert_belgium_list(coords, false)
  end

  test "Explicit Geocode.OpenStreetMaps data: latlng" do
    {:ok, coords} = Geocoder.call(Geocoder.OpenStreetMaps.new({51.0775264, 3.7073382}), provider: Geocoder.OpenStreetMaps)
    assert_belgium(coords)
  end

  test "Explicit Geocode.OpenStreetMaps data: address" do
    {:ok, coords} = Geocoder.call(Geocoder.OpenStreetMaps.new("Dikkelindestraat 46, 9032 Wondelgem, Belgium"), provider: Geocoder.OpenStreetMaps)
    assert_belgium(coords)
  end

  test "Explicit Geocode.OpenStreetMaps list: latlng" do
    {:ok, coords} = Geocoder.call_list(Geocoder.OpenStreetMaps.new({51.0775264, 3.7073382}), provider: Geocoder.OpenStreetMaps)
    assert_belgium_list(coords, false)
  end

  @tag :pending
  test "Explicit Geocode.OpenStreetMaps list: address" do
    {:ok, coords} = Geocoder.call_list(Geocoder.OpenStreetMaps.new("Dikkelindestraat 46, 9032 Wondelgem, Belgium"), provider: Geocoder.OpenStreetMaps)
    assert_belgium_list(coords, false)
  end

  defp assert_belgium(coords) do
    bounds = coords |> Geocoder.Data.bounds

    # Bounds are not always returned
    if bounds.bottom, do: assert bounds.bottom |> Float.round == 51
    if bounds.left,   do: assert bounds.left |> Float.round == 4
    if bounds.right,  do: assert bounds.right |> Float.round == 4
    if bounds.top,    do: assert bounds.top |> Float.round == 51

    location = coords |> Geocoder.Data.location
    if location.street_number, do: assert location.street_number == "46"
    if location.street, do: assert location.street == "Dikkelindestraat"
    if location.city, do: assert location.city |> String.match?(~r/^Gh?ent$/)
    if location.country, do: assert location.country == "Belgium"
    if location.country_code, do: assert location.country_code |> String.upcase == "BE"
    if location.postal_code, do: assert location.postal_code == "9032"
    #      lhs:  "Dikkelindestraat, Wondelgem, Ghent, Gent, East Flanders, Flanders, 9032, Belgium"
    #      rhs:  "Dikkelindestraat 46, 9032 Gent, Belgium"
    if location.formatted_address do
      assert location.formatted_address |> String.match?(~r/Dikkelindestraat/)
      assert location.formatted_address |> String.match?(~r/Gh?ent/)
      assert location.formatted_address |> String.match?(~r/9032/)
      assert location.formatted_address |> String.match?(~r/Belgium/)
    end

    %Geocoder.Coords{lat: lat, lon: lon} = coords |> Geocoder.Data.latlng
    assert lat |> Float.round == 51
    assert lon |> Float.round == 4
  end

  defp assert_belgium_list(result, _single) do
    assert is_list(result)
    assert [head|_tail] = result
    # assert (if single, do: tail |> Enum.empty?, else: not(tail |> Enum.empty?))
    assert_belgium(head)
  end

end
