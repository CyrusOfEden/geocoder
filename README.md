# Geocoder

[![Build Status](https://github.com/knrz/geocoder/actions/workflows/elixir.yml/badge.svg)](https://github.com/knrz/geocoder/actions/workflows/elixir.yml)
[![Inline docs](http://inch-ci.org/github/knrz/geocoder.svg?branch=master)](http://inch-ci.org/github/knrz/geocoder)
[![Coverage Status](https://coveralls.io/repos/github/knrz/geocoder/badge.svg?branch=master)](https://coveralls.io/github/knrz/geocoder?branch=master)
[![Module Version](https://img.shields.io/hexpm/v/geocoder.svg)](https://hex.pm/packages/geocoder)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/geocoder/)
[![Total Download](https://img.shields.io/hexpm/dt/geocoder.svg)](https://hex.pm/packages/geocoder)
[![License](https://img.shields.io/hexpm/l/geocoder.svg)](https://github.com/knrz/geocoder/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/knrz/geocoder.svg)](https://github.com/knrz/geocoder/commits/master)

A simple, efficient geocoder/reverse geocoder with a built-in cache.

Is it extensible? Yes.
**Is it any good?** Absolutely.

## Installation

Keep calm and add `:geocoder` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:geocoder, "~> 1.1"}
  ]
end
```

Update your mix dependencies:

```bash
mix deps.get
```

If you are Elixir < 1.9, you'll need to use a version before `1.0`.

## Configuration

### Prod & Dev

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

If you need to set a proxy (or any other option supported by `HTTPoison.get/3`):

```elixir
config :geocoder, Geocoder.Worker, [
  httpoison_options: [proxy: "my.proxy.server:3128", proxy_auth: {"username", "password"}]
]
```

If you want to change the cache precision (defaults to `6`):

```elixir
config :geocoder, Geocoder.Store, precision: 6
```
### Test

To avoid making external requests in the context of the test suite, usage of the [`Fake`](./lib/geocoder/providers/fake.ex) provider is recommended.

The fake provider can be configured by adding a `:data` tuple to the `Geocoder.Worker` configuration as shown below.

The keys of the data map must be in either [regex](https://hexdocs.pm/elixir/Regex.html) or
[tuple](https://hexdocs.pm/elixir/Tuple.html) format (specifically a `{lat, lng}` style pair of floats).

```elixir
# config/test.exs
config :geocoder, :worker,
  provider: Geocoder.Providers.Fake

config :geocoder, Geocoder.Worker,
  data: %{
    ~r/.*New York, NY.*/ => %{
      lat: 40.7587905,
      lon: -73.9787755,
      bounds: %{
        bottom: 40.7587405,
        left: -73.9788255,
        right: -73.9787255,
        top: 40.7588405,
      },
      location: %{
        city: "New York",
        country: "United States",
        country_code: "us",
        county: "New York County", 
        formatted_address: "30 Rockefeller Plaza, New York, NY 10112, United States of America",
        postal_code: "10112",
        state: "New York",
        street: "Rockefeller Plaza",
        street_number: "30"
      },
    },
    {40.7587905, -73.9787755} => %{
      lat: 40.7587905,
      lon: -73.9787755,
      bounds: %{
        bottom: 40.7587405,
        left: -73.9788255,
        right: -73.9787255,
        top: 40.7588405,
      },
      location: %{
        city: "New York",
        country: "United States",
        country_code: "us",
        county: "New York County", 
        formatted_address: "30 Rockefeller Plaza, New York, NY 10112, United States of America",
        postal_code: "10112",
        state: "New York",
        street: "Rockefeller Plaza",
        street_number: "30"
      },
    }
  }
```

Let's rumble!

## Usage

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

## Extension


Any additional Providers must implement all of the following functions:

```
geocode/1
geocode_list/1
reverse_geocode/1
reverse_geocode_list/1
```

## Development

Right now, `:geocoder` supports three external providers (i.e. sources):

* `Geocoder.Providers.GoogleMaps`
* `Geocoder.Providers.OpenCageData`
* `Geocoder.Providers.OpenStreetMaps`

To run the tests for these, and any future providers, you'll want to pass a `PROVIDER` environment variable:

```
PROVIDER=google mix test
```

By default, the tests against the [`Fake`](./lib/geocoder/providers/fake.ex) provider.

## Related & Alternative Packages

* https://github.com/amotion-city/lib_lat_lon
* https://github.com/navinpeiris/geoip
* https://github.com/elixir-geolix/geolix

## Copyright and License

Copyright (c) 2015 Kash Nouroozi

The source code is licensed under the [MIT License](./LICENSE.md).
