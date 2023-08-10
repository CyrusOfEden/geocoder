defmodule Geocoder.Coords do
  @moduledoc false

  defstruct lat: nil,
            lon: nil,
            bounds: %Geocoder.Bounds{},
            location: %Geocoder.Location{},
            partial_match: nil
end
