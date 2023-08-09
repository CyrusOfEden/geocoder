defmodule GeocoderTest do
  use ExUnit.Case, async: true

  import Geocoder.Support.Helpers
  import Hammox

  setup :verify_on_exit!

  setup do
    # you can select to run this set of test with any of the
    # supported providers and they should normally pass
    #
    # just run:
    #
    # PROVIDER=google API_KEY=key mix test
    #
    key = System.get_env("API_KEY", "NO_API_KEY")
    provider = System.get_env("PROVIDER", "fake")
    config = provider_test_config(provider, key)

    start_supervised({Geocoder.Supervisor, config})
    {:ok, provider: provider}
  end

  test "An address in New York" do
    {:ok, coords} = Geocoder.call("1991 15th Street, Troy, NY 12180")
    assert_new_york(coords)
  end

  test "An address in Belgium" do
    {:ok, coords} = Geocoder.call("Dikkelindestraat 46, 9032 Wondelgem, Belgium")
    assert_belgium(coords)
  end

  test "An address that returns a partial match", %{provider: provider} do
    if provider == "fake" do
      {:ok, coords} = Geocoder.call("Rua não, 101, São Paulo, Brazil")
      assert_sao_paulo(coords)
    end
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
end
