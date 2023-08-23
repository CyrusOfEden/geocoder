# Geocoder

[![Build Status](https://github.com/knrz/geocoder/actions/workflows/elixir.yml/badge.svg)](https://github.com/knrz/geocoder/actions/workflows/elixir.yml)
[![Inline docs](http://inch-ci.org/github/knrz/geocoder.svg?branch=master)](http://inch-ci.org/github/knrz/geocoder)
[![Coverage Status](https://coveralls.io/repos/github/knrz/geocoder/badge.svg?branch=master)](https://coveralls.io/github/knrz/geocoder?branch=master)
[![Module Version](https://img.shields.io/hexpm/v/geocoder.svg)](https://hex.pm/packages/geocoder)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/geocoder/)
[![Total Download](https://img.shields.io/hexpm/dt/geocoder.svg)](https://hex.pm/packages/geocoder)
[![License](https://img.shields.io/hexpm/l/geocoder.svg)](https://github.com/knrz/geocoder/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/knrz/geocoder.svg)](https://github.com/knrz/geocoder/commits/master)

A simple, efficient geocoder/reverse geocoder with a built-in cache. This libary is quite felxible and extensible. You can pretty much extend any part of geocoder: caching store, workers, http client, JSON Codec, Provider, etc..

It supports the current providers out of box
- Google map
- OpenCageData
- Openstreet maps

It supports the current http clients out of the box
- :httpoison
- :hackney

It supports the current http clients out of the box
- :jason
- :jsx

It supports the current caching store out of the box
- In memory store (`Geocoder.Store`)

## Installation

add `:geocoder` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:geocoder, "~> 2.0"}
  ]
end
```

Update your mix dependencies:

```bash
mix deps.get
```

**Notes:** If you are Elixir < 1.9, you'll need to use a version before `1.0`.

## Configuration

Configuration is done by passing options to the `Geocoder.Supervisor`. See the `Geocoder.Config` for all possible configuration options. But you can just get started
by adding this to your application tree

```elixir
[
  Geocoder.Supervisor,
]
```

This will start the geocoder processes with all the default options, and should be compatible with 1.x (process + API + functionality)

### Using a different Provider

The default client for Geocoder is OpenStreeMaps. You can easily switch to other providers  option. Or you can build your own as long as you implement the behavior `Geocoder.Provider` correctly. You can look at some examples inside the `lib/geocoder/providers/*`

Then you can configure the different or custom provider with the following configuration:

```elixir
[
  {Geocoder.Supervisor, worker_config: [provider: MyApp.Client,  key: "some_api_key"]},
]
```
**NOTES**: OpenStreetMaps does not require key. Others provider do.

### Using a different HTTP Client

The default client for Geocoder is HTTPoison. You can easily switch to Hackney as it comes as an option. Or you can build your own as long as you implement the behavior `Geocoder.HttpClient` correctly in your client


Then you can configure the different or custom client with the following configuration:

```elixir
[
  {Geocoder.Supervisor, worker_config: [http_client: MyApp.Client,  http_client_opts: []]}
]
```

If you need to set a proxy (or any other option supported by `HTTPoison.get/3`):

```elixir
[
  {Geocoder.Supervisor, worker_config:
    [
      http_client_opts: [proxy: "my.proxy.server:3128", proxy_auth: {"username", "password"}]
    ]
   }
  ...
]
```

### Using a different Store

The default caching store is `Geocoder.Store`. This is a simple in memory cache (in a process basically) and is started by default.

If you want to change the Store, you can provide your own store implementation as well. See how the `Geocoder.Store` is implemented for an example. Then you will need to configure it using:

```elixir
[
  {Geocoder.Supervisor, store_module: MyApp.MyStore},
  ...
]
```
### JSON Codec Configuration

The default JSON codec is Jason. You can create you custom codec or use different one as long as you implement the behavior `Geocoder.JSONCodec`.

Then you can configure the different or custom JSON codec with the following configuration:

```elixir
[
  {Geocoder.Supervisor, worker_config:
    [
      json_codec: Jason
    ]
   }
  ...
]
```

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
    {:error, nil} <- Geocoder.call(query, worker_config: [provider: Geocoder.Providers.OpenCageData, key: "123"]),
    do: {:error}
```

See [here](https://developers.google.com/maps/documentation/geocoding/intro#geocoding) and [here](https://developers.google.com/maps/documentation/geocoding/intro#ReverseGeocoding) for a list of supported parameters for the google maps geocoder provider (`Geocoder.Provider.GoogleMaps`).

And you're done! How simple was that?

## Development

Right now, `:geocoder` supports three external providers (i.e. sources):

* `Geocoder.Providers.GoogleMaps`
* `Geocoder.Providers.OpenCageData`
* `Geocoder.Providers.OpenStreetMaps`

To run the tests for these, and any future providers, you'll want to pass a `PROVIDER` environment variable as well as the `API_KEY`:

```shell
PROVIDER=google API_KEY="mykey" mix test
```

By default, the tests against the [`Fake`](./lib/geocoder/providers/fake.ex) provider.

To avoid making external requests in the context of the test suite, usage of the [`Fake`](./lib/geocoder/providers/fake.ex) provider is recommended.

The fake provider can be configured by adding a `:data` tuple to the configuration as shown below.

The keys of the data map must be in either [regex](https://hexdocs.pm/elixir/Regex.html) or
[tuple](https://hexdocs.pm/elixir/Tuple.html) format (specifically a `{lat, lng}` style pair of floats).

```elixir
[
  {Geocoder.Supervisor, worker_config:
    [
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
    ]
   }
  ...
]
```

## Related & Alternative Packages

* https://github.com/amotion-city/lib_lat_lon
* https://github.com/navinpeiris/geoip
* https://github.com/elixir-geolix/geolix

## Copyright and License

Copyright (c) 2023 Cyrus Nouroozi

The source code is licensed under the [MIT License](./LICENSE.md).
