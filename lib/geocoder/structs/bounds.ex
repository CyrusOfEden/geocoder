defmodule Geocoder.Bounds do
  @moduledoc false

  @type t :: %__MODULE__{
          top: float() | nil,
          right: float() | nil,
          bottom: float() | nil,
          left: float() | nil
        }

  defstruct top: nil, right: nil, bottom: nil, left: nil
end
