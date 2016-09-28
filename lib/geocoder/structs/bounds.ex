defmodule Geocoder.Bounds do
  defstruct top: nil, right: nil, bottom: nil, left: nil

  defimpl String.Chars, for: Geocoder.Bounds do
    def to_string(data) do
      "#{data.top},#{data.right}|#{data.bottom},#{data.left}"
    end
  end
end
