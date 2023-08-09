defmodule Geocoder.JSONCodec do
  @moduledoc """
  Defines the specification for a JSON codec.

  Geocoder supports the use of your favorite JSON codec provided it fulfills this specification.
  Jason fulfills this spec without modification, and is the default for now.

  Other codecs:
  - Jason:
    Make sure to add the dependency to you `mix.exs` file

    ```
    {:jason, "~> 1.4"},
    ```

    In your config you would do:

    ```elixir
      config :geocoder,
        json_codec: Jason
    ```
  - JSX:
      Make sure to add the dependency to you `mix.exs` file

      ```
      {:jsx, "~> 2.8 or ~> 3.0"},
      ```

      In your config you would do:

      ```elixir
        config :geocoder,
        json_codec: Geocoder.JSON.JSX
      ```
  - Poison:
    Make sure to add the dependency to you `mix.exs` file

    ```
    {:poison, "~> 5.0"},
    ```

    In your config you would do:

    ```elixir
      config :geocoder,
        json_codec: Poison
    ```

  If you need another one that does not match the specification, see the contents of `Geocoder.JSON.JSX` for an example of an alternative implementation.
  """

  @callback encode!(%{}) :: String.t()
  @callback encode(%{}) :: {:ok, String.t()} | {:error, String.t()}

  @callback decode!(String.t()) :: %{}
  @callback decode(String.t()) :: {:ok, %{}} | {:error, %{}}
end
