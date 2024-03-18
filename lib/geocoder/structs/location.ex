defmodule Geocoder.Location do
  @moduledoc false

  @type t :: %__MODULE__{
          city: String.t() | nil,
          state: String.t() | nil,
          county: String.t() | nil,
          country: String.t() | nil,
          postal_code: String.t() | nil,
          street: String.t() | nil,
          street_number: String.t() | nil,
          country_code: String.t() | nil,
          formatted_address: String.t() | nil
        }
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
