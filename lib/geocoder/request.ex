defmodule Geocoder.Request do
  @moduledoc """
  This is the actual request logic to abstract a client implementation and use supported clients specified
  for all providers in a uniform way.

  Common logic (retry, etc) to clients should be added here. Otherwise let the client implement their own specific
  needs
  """

  alias Geocoder.Request.HttpClient

  @spec request(HttpClient.request(), HttpClient.config()) ::
          {:ok, %{status_code: pos_integer, headers: any}}
          | {:ok, %{status_code: pos_integer, headers: any, body: binary}}
          | {:error, any}
  def request(request, config \\ []) do
    http_client = config[:http_client]

    http_client.request(
      request,
      config
    )
  end
end
