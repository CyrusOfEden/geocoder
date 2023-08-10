defmodule Geocoder.Providers.OpenStreetMapsTest do
  use ExUnit.Case, async: true

  alias Geocoder.Providers.OpenStreetMaps

  import Hammox
  import Geocoder.Support.Helpers

  setup :verify_on_exit!

  describe "geocode/1" do
    test "make a valid request" do
      Geocoder.HttpClientMock
      |> expect(:request, fn req, _config ->
        assert req == %{
                 method: :get,
                 query_params: %{
                   "accept-language": "en",
                   address: "Dikkelindestraat 46, 9032 Wondelgem, Belgium",
                   addressdetails: 1,
                   format: "json",
                   q: "Dikkelindestraat 46, 9032 Wondelgem, Belgium"
                 },
                 url: "https://nominatim.openstreetmap.org/search"
               }

        {:ok,
         %{
           status_code: 200,
           headers: [],
           body: belgium_openstreetmap_payload()
         }}
      end)

      {:ok, coords} =
        OpenStreetMaps.geocode(
          [
            store: Geocoder.Store,
            provider: Geocoder.Providers.OpenStreetMaps,
            address: "Dikkelindestraat 46, 9032 Wondelgem, Belgium"
          ],
          http_client: Geocoder.HttpClientMock
        )

      assert_belgium(coords)
    end
  end

  describe "geocode_list/1" do
    test "make a valid request" do
      Geocoder.HttpClientMock
      |> expect(:request, fn req, _config ->
        assert req == %{
                 method: :get,
                 query_params: %{
                   "accept-language": "en",
                   address: "Dikkelindestraat 46, 9032 Wondelgem, Belgium",
                   addressdetails: 1,
                   format: "json",
                   q: "Dikkelindestraat 46, 9032 Wondelgem, Belgium"
                 },
                 url: "https://nominatim.openstreetmap.org/search"
               }

        {:ok,
         %{
           status_code: 200,
           headers: [],
           body: belgium_openstreetmap_payload()
         }}
      end)

      {:ok, coords} =
        OpenStreetMaps.geocode_list(
          [
            store: Geocoder.Store,
            provider: Geocoder.Providers.OpenStreetMaps,
            address: "Dikkelindestraat 46, 9032 Wondelgem, Belgium"
          ],
          http_client: Geocoder.HttpClientMock
        )

      assert is_list(coords)
      assert Enum.count(coords) > 0
      assert_belgium(coords |> List.first())
    end
  end

  describe "reverse_geocode/1" do
    test "make a valid request" do
      Geocoder.HttpClientMock
      |> expect(:request, fn req, _config ->
        assert req == %{
                 method: :get,
                 query_params: %{
                   "accept-language": "en",
                   addressdetails: 1,
                   format: "json",
                   q: "51.0775264,3.7073382",
                   lat: 51.0775264,
                   lon: 3.7073382
                 },
                 url: "https://nominatim.openstreetmap.org/reverse"
               }

        {:ok,
         %{
           status_code: 200,
           headers: [],
           body: belgium_openstreetmap_payload()
         }}
      end)

      {:ok, coords} =
        OpenStreetMaps.reverse_geocode(
          [
            store: Geocoder.Store,
            provider: Geocoder.Providers.Fake,
            lat: 51.0775264,
            lon: 3.7073382,
            latlng: {51.0775264, 3.7073382}
          ],
          http_client: Geocoder.HttpClientMock
        )

      assert_belgium(coords)
    end
  end

  describe "reverse_geocode_list/1" do
    test "make a valid request" do
      Geocoder.HttpClientMock
      |> expect(:request, fn req, _config ->
        assert req == %{
                 method: :get,
                 query_params: %{
                   "accept-language": "en",
                   addressdetails: 1,
                   format: "json",
                   q: "51.0775264,3.7073382"
                 },
                 url: "https://nominatim.openstreetmap.org/search"
               }

        {:ok,
         %{
           status_code: 200,
           headers: [],
           body: belgium_openstreetmap_payload()
         }}
      end)

      {:ok, coords} =
        OpenStreetMaps.reverse_geocode_list(
          [
            store: Geocoder.Store,
            provider: Geocoder.Providers.Fake,
            latlng: {51.0775264, 3.7073382}
          ],
          http_client: Geocoder.HttpClientMock
        )

      assert is_list(coords)
      assert Enum.count(coords) > 0
      assert_belgium(coords |> List.first())
    end
  end
end
