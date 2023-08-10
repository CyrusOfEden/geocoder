defmodule Geocoder.JSONCodec.JSX do
  @moduledoc """
  Implementation of the codec for the JSX library
  """

  @behaviour Geocoder.JSONCodec

  if Code.ensure_loaded?(:jsx) do
    def encode!(%{} = map) do
      map |> :jsx.encode()
    end

    def decode!(string) do
      :jsx.decode(string, [:return_maps])
    end
  else
    def encode!(_) do
      raise ":jsx must be added as a dependency to use this module"
    end

    def decode!(_) do
      raise ":jsx must be added as a dependency to use this module"
    end
  end

  def encode(map) do
    {:ok, encode!(map)}
  rescue
    ArgumentError -> {:error, :badarg}
  end

  def decode(string) do
    {:ok, decode!(string)}
  rescue
    ArgumentError -> {:error, :badarg}
  end
end
