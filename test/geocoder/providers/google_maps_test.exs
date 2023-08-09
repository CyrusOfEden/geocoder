defmodule Geocoder.Providers.GoogleMapsTest do
  use ExUnit.Case, async: true

  alias Geocoder.Providers.GoogleMaps

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
                   address: "Dikkelindestraat 46, 9032 Wondelgem, Belgium",
                   key: nil,
                   latlng: nil
                 },
                 url: "https://maps.googleapis.com/maps/api/geocode/json"
               }

        {:ok,
         %{
           status_code: 200,
           headers: [],
           body: belgium_googlemap_payload()
         }}
      end)

      {:ok, coords} =
        GoogleMaps.geocode(
          [
            store: Geocoder.Store,
            provider: Geocoder.Providers.GoogleMaps,
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
                   address: "Dikkelindestraat 46, 9032 Wondelgem, Belgium",
                   key: nil,
                   latlng: nil
                 },
                 url: "https://maps.googleapis.com/maps/api/geocode/json"
               }

        {:ok,
         %{
           status_code: 200,
           headers: [],
           body: belgium_googlemap_payload()
         }}
      end)

      {:ok, coords} =
        GoogleMaps.geocode_list(
          [
            store: Geocoder.Store,
            provider: Geocoder.Providers.GoogleMaps,
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
                 query_params: %{key: nil, latlng: "51.0775264,3.7073382"},
                 url: "https://maps.googleapis.com/maps/api/geocode/json"
               }

        {:ok,
         %{
           status_code: 200,
           headers: [],
           body: belgium_googlemap_payload()
         }}
      end)

      {:ok, coords} =
        GoogleMaps.reverse_geocode(
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
                 query_params: %{key: nil, latlng: "51.0775264,3.7073382"},
                 url: "https://maps.googleapis.com/maps/api/geocode/json"
               }

        {:ok,
         %{
           status_code: 200,
           headers: [],
           body: belgium_googlemap_payload()
         }}
      end)

      {:ok, coords} =
        GoogleMaps.reverse_geocode_list(
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
