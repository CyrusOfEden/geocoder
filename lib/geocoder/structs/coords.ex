defmodule Geocoder.Coords do
  @moduledoc false

  @type t :: %__MODULE__{
          lat: float() | nil,
          lon: float() | nil,
          bounds: Geocoder.Bounds.t() | nil,
          location: Geocoder.Location.t() | nil,
          partial_match: boolean() | nil
        }

  defstruct lat: nil,
            lon: nil,
            bounds: %Geocoder.Bounds{},
            location: %Geocoder.Location{},
            partial_match: nil
end
