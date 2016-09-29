defmodule Geocoder.QueryParams do
  defstruct language: nil,
            # commercials below
            key: nil,
            region: nil,
            location_type: nil

  def new(query_params) when is_map(query_params) do
    new(query_params |> Map.to_list)
  end

  def new(query_params) when is_list(query_params) do
    %Geocoder.QueryParams{}
      |> Map.merge(query_params
                    |> Keyword.take(~W{region location_type key language}a)
                    |> Enum.into(%{}))
  end

  def to_map(query_params) do
    query_params
      |> Map.delete(:__struct__)
      |> Enum.reduce(%{}, fn {k, v}, acc ->
           if v == nil, do: acc, else: acc |> Map.put(k, v)
         end)
  end

  def to_keyword(query_params) do
    query_params |> to_map |> Map.to_list
  end

  ##############################################################################

  defimpl Geocoder.Request, for: Geocoder.QueryParams do
    def region(data) do
      data.region
    end

    def location_type(data) do
      data.location_type
    end

    def key(data) do
      data.key
    end

    def language(data) do
      data.language
    end
  end
end
