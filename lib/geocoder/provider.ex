defmodule Geocoder.Provider do
  @moduledoc """
  Specifies expected behaviour for a provider
  """
  alias Geocoder.Coords

  @type payload :: keyword()

  @type option ::
          {:json_codec, atom()}
          | {:http_client, atom()}
          | {:http_client_opts, term()}
          | {:key, binary()}
          | {:data, term()}

  @type options :: [option()]

  @callback geocode(payload(), options()) :: {:ok, Coords.t()} | {:error, any()}

  @callback geocode_list(payload(), options()) :: {:ok, Coords.t()} | {:error, any()}

  @callback reverse_geocode(payload(), options()) :: {:ok, Coords.t()} | {:error, any()}

  @callback reverse_geocode_list(payload(), options()) :: {:ok, Coords.t()} | {:error, any()}
end
