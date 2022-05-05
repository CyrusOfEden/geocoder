defmodule Geocoder.Providers.Fake do
  use Towel

  def geocode(opts) do
    look_up_in_config(opts[:address])
    |> parse_geocode()
  end

  def geocode_list(opts) do
    geocode(opts)
  end

  def reverse_geocode(opts) do
    look_up_in_config(opts[:latlng])
    |> parse_geocode()
  end

  def reverse_geocode_list(opts) do
    reverse_geocode(opts)
  end

  defp parse_geocode(nil), do: {:error, nil}

  defp parse_geocode(loaded_config) do
    coords = geocode_coords(loaded_config)
    bounds = geocode_bounds(loaded_config[:bounds])
    location = geocode_location(loaded_config[:location])
    {:ok, %{coords | bounds: bounds, location: location}}
  end

  defp geocode_coords(%{lat: lat, lon: lon}) do
    %Geocoder.Coords{lat: lat, lon: lon}
  end

  defp geocode_coords(_), do: %Geocoder.Coords{}

  defp geocode_bounds(%{top: north, right: east, bottom: south, left: west}) do
    %Geocoder.Bounds{top: north, right: east, bottom: south, left: west}
  end

  defp geocode_bounds(_), do: %Geocoder.Bounds{}

  defp geocode_location(nil), do: %Geocoder.Location{}

  defp geocode_location(location_attrs) do
    Map.merge(%Geocoder.Location{}, location_attrs)
  end

  defp look_up_in_config(key) do
    Geocoder.worker_config()[:data][key]
  end
end
