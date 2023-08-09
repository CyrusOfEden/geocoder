defmodule Geocoder.HttpClient do
  @moduledoc """
  Specifies expected behaviour of an HTTP client.

  Geocoder allows you to use your HTTP client of choice, provided that
  it can be coerced into complying with this module's specification.

  The default client is `:httpoison`.

  Other supported clients:
  - Hackney:
    Make sure to add the dependency to you `mix.exs` file

    ```
    {:hackney, "~> 1.18"},
    ```
  - Httpoison:
    Make sure to add the dependency to you `mix.exs` file

    ```
    {:httpoison, "~> 2.1"},
    ```

  See `lib/geocoder/http_client/http_poison.ex` for an implementation example

  When conforming your selected HTTP Client take note of a few things:

    - The module name doesn't need to follow the same styling as this module it
      is simply your own 'HTTP Client', i.e. `MyApp.HttpClient`

    - The request function must accept the methods as described in the
      `c:request/2` callback, you can however set these as optional,
      i.e. `config \\ []`

    - You will need to manage the body encoding and decoding properly
      by using the the config[:json_codec] to keep it flexible

    - You will need to manage the query_params encoding if needed. This depends
      the internal client support for this

    - Ensure the call to your chosen HTTP Client is correct and the return is
      in the same format as defined in the `c:request/2` callback
  """

  @type http_method :: :get | :post | :put | :delete | :options | :head

  @type request :: %{
          :method => http_method(),
          :url => binary(),
          optional(:body) => binary() | nil,
          optional(:headers) => [{binary, binary}, ...] | [],
          optional(:query_params) => map()
        }

  @type option ::
          {:json_codec, atom()}
          | {:http_client, atom()}
          | {:http_client_opts, term()}

  @type config :: [option()]

  @callback request(
              request(),
              config()
            ) ::
              {:ok, %{status_code: pos_integer, headers: any}}
              | {:ok, %{status_code: pos_integer, headers: any, body: any()}}
              | {:error, any}
end
