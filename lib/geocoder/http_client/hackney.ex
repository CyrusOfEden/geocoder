defmodule Geocoder.HttpClient.Hackney do
  @moduledoc """
  Hackney client. See Hackney for documentation for options that can be passed
  in the http_client_opts
  """
  @behaviour Geocoder.HttpClient

  if Code.ensure_loaded?(:hackney) do
    def request(%{method: method, url: url, query_params: params} = request, config \\ []) do
      http_client_opts = config[:http_client_opts]
      json_codec = config[:json_codec]
      opts = [:with_body | http_client_opts] ++ [ibrowse: [headers_as_is: true], params: params]
      headers = request[:headers] || []

      final_url = build_url(url, params)

      case :hackney.request(method, final_url, headers, "", opts) do
        {:ok, status, headers} ->
          {:ok, %{status_code: status, headers: headers}}

        {:ok, status, headers, body} ->
          {:ok, %{status_code: status, headers: headers, body: json_codec.decode!(body)}}

        {:error, reason} ->
          {:error, %{reason: reason}}
      end
    end

    defp build_url(url, query_params) do
      if Enum.empty?(query_params) do
        url
      else
        url <> "?" <> :hackney_url.qs(Map.to_list(query_params))
      end
    end
  end
end
