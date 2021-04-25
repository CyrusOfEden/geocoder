Geocoder ![Build Status](https://github.com/knrz/geocoder/actions/workflows/elixir.yml/badge.svg) [![Inline docs](http://inch-ci.org/github/knrz/geocoder.svg?branch=master)](http://inch-ci.org/github/knrz/geocoder) [![Coverage Status](https://coveralls.io/repos/github/knrz/geocoder/badge.svg?branch=master)](https://coveralls.io/github/knrz/geocoder?branch=master)
========

A simple, efficient geocoder/reverse geocoder with a built-in cache.

Is it extensible? Yes.
**Is it any good?** Absolutely.

Installation
------------

Keep calm and add Geocoder to your `mix.exs` dependencies:

```elixir
def deps do
  [{:geocoder, "~> 1.1"}]
end
```

Update your mix dependencies:

```bash
mix deps.get
```

If you are Elixir < 1.9, you'll need to use a version before `1.0`.

Configuration
-------------

All configuration below is optional. Sane defaults are set so you don't need to think too hard.

Set pool configuration:

```elixir
config :geocoder, :worker_pool_config, size: 4, max_overflow: 2
```

Set provider configuration:

```elixir
config :geocoder, :worker,
  # OpenStreetMaps or OpenCageData are other supported providers
  provider: Geocoder.Providers.GoogleMaps,
  key: System.get_env("GEOCODER_GOOGLE_API_KEY")
```

Note that `OpenStreetMaps` (the default provider) is the only provider that does not require an API key to operate.
All other providers require an API key that you'll need to provide.

If you need to set a proxy (or any other option supported by HTTPoison.get/3):

```elixir
config :geocoder, Geocoder.Worker, [
  httpoison_options: [proxy: "my.proxy.server:3128", proxy_auth: {"username", "password"}]
]
```

Let's rumble!

Usage
-----

```elixir
{:ok, coordinates } = Geocoder.call("Toronto, ON")
{:ok, coordinates } = Geocoder.call({43.653226, -79.383184})

coordinates.location.formatted_address
```

You can pass options to the function that will be passed to the geocoder provider, for example:

```elixir
Geocoder.call(address: "Toronto, ON", language: "es", key: "...", ...)
```

You can also change the provider on a per-call basis:

```elixir
{:ok, coordinates } =
  with
    # use the default provider
    {:error, nil} <- Geocoder.call(query),
    # use an alternative provider. If `key` is not specified here the globally defined key will be used.
    {:error, nil} <- Geocoder.call(query, provider: Geocoder.Providers.OpenCageData, key: "123"),
    do: {:error}
```

See [here](https://developers.google.com/maps/documentation/geocoding/intro#geocoding) and [here](https://developers.google.com/maps/documentation/geocoding/intro#ReverseGeocoding) for a list of supported parameters for the google maps geocoder provider (`Geocoder.Provider.GoogleMaps`).

And you're done! How simple was that?

Development
-----------

Right now, `geocoder` supports three providers (i.e. sources):

* `Geocoder.Providers.GoogleMaps`
* `Geocoder.Providers.OpenCageData`
* `Geocoder.Providers.OpenStreetMaps`

To run the tests for these, and any future providers, you'll want to pass a `PROVIDER` environment variable:

```
PROVIDER=google mix test
```

By default, the tests run on OpenStreetMaps.

## Copyright and License

Copyright (c) 2019, Kash Nouroozi.

The source code is licensed under the [MIT License](LICENSE.md).
