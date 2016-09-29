defmodule ProviderTest do
  use ExUnit.Case

  test "Worker responds to provider?" do
    {:ok, provider} = Geocoder.Worker.provider?
    assert provider == Geocoder.GoogleMaps
  end

  test "Worker allows resetting provider" do
    {:ok, provider} = Geocoder.Worker.provider!(Geocoder.Providers.OpenStreetMaps)
    assert provider == Geocoder.GoogleMaps
    {:ok, provider} = Geocoder.Worker.provider?
    assert provider == Geocoder.Providers.OpenStreetMaps
    {:ok, provider} = Geocoder.Worker.provider!(%Geocoder.GoogleMaps{})
    assert provider == Geocoder.Providers.OpenStreetMaps
    {:ok, provider} = Geocoder.Worker.provider?
    assert provider == Geocoder.GoogleMaps
  end

end
