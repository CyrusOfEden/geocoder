defmodule Geocoder.Location do
  defstruct city: nil,
            state: nil,
            county: nil,
            country: nil,
            postal_code: nil,
            street: nil,
            street_number: nil,
            country_code: nil,
            formatted_address: nil
end
