defmodule Geocoder.RequestTest do
  use ExUnit.Case, async: false

  alias Geocoder.Request
  import Hammox

  setup :verify_on_exit!

  test "make a request to the specified client in config" do
    request = %{
      method: :get,
      url: "http://example.com",
      query_params: %{},
      body: "",
      headers: []
    }

    config = [
      http_client: Geocoder.HttpClientMock,
      json_codec: Jason
    ]

    Geocoder.HttpClientMock
    |> expect(:request, fn req, config ->
      assert request == req

      assert config == [
               http_client: Geocoder.HttpClientMock,
               json_codec: Jason
             ]

      {:ok, %{status_code: 200, headers: [], body: "some body"}}
    end)

    assert {:ok, %{status_code: 200, headers: [], body: "some body"}} ==
             Request.request(request, config)
  end
end
