defmodule Geocoder.Provider do
  @moduledoc """
    `Geocoder` uses a concept of providers. Provider should implement
    `Geocoder.Data` protocol, what allows different providers to be operated
    in the unified manner.

    Currently there are two providers available:

    - Geocoder.GoogleMaps
    - Geocoder.OpenStreetMaps
  """

  use HTTPoison.Base

  ##############################################################################

  def go!(data, params \\ %Geocoder.QueryParams{}, provider \\ Geocoder.Worker.provider?)

  def go!(data, %Geocoder.QueryParams{} = params, provider) do # Geocoder.Worker.provider?
    input = if Geocoder.Data.impl_for(data) == nil, do: apply(provider, :new, [data]), else: data
    direction = if input |> Geocoder.Data.latlng, do: :reverse, else: :direct

    params = Keyword.merge(
      Application.get_env(:geocoder, Geocoder.Worker)[:httpoison_options] || [],
      params: params |> Geocoder.QueryParams.to_map |> Map.merge(input |> Geocoder.Data.query(direction) |> Enum.into(%{}))
    )

    case get(input |> Geocoder.Data.endpoint(direction), [], params) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, apply(provider, :new, [body |> Poison.decode!])}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :not_found}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  def go!(data, params, provider) when is_list(params) do #
    go!(data, Geocoder.QueryParams.new(params), provider)
  end

  ##############################################################################

  ##############################################################################

  def atomize_keys(map) when is_map(map) do
    for {k, v} <- map, into: %{} do
      {String.to_atom(k), atomize_keys(v)}
    end
  end
  def atomize_keys(list) when is_list(list) do
    list |> Enum.map(&atomize_keys(&1))
  end
  def atomize_keys(val), do: val

end
