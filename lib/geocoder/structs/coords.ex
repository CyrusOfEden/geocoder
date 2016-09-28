defmodule Geocoder.Coords do
  defstruct lat: nil,
            lon: nil,
            bounds: %Geocoder.Bounds{},
            location: %Geocoder.Location{}

  defimpl String.Chars, for: Geocoder.Coords do
    def to_string(data) do
      "#{data.lat},#{data.lon}"
    end
  end
end
