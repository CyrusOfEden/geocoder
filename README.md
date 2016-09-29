Geocoder [![Build Status](https://travis-ci.org/knrz/geocoder.svg?branch=master)](https://travis-ci.org/knrz/geocoder)
========

A simple, efficient geocoder/reverse geocoder with a built-in cache.

Is it extensible? Yes.
**Is it any good?** Absolutely.

Installation
------------

Keep calm and add Geocoder to your `mix.exs` dependencies:

```elixir
def deps do
  [{:geocoder, "~> 0.7"}]
end
```

Add it to your starting applications too:

```elixir
def application do
  [applications: [:logger, :geocoder]]
end
```

Set pool configuration:

```elixir
config :geocoder, Geocoder.Worker, [
  size: 4,
  max_overflow: 2
]
```

Set store configuration:

```elixir
config :geocoder, Geocoder.Store, [
  precision: 4 # the default
]
```

If you need to set a proxy (or any other option supported by HTTPoison.get/3):

```elixir
config :geocoder, Geocoder.Worker, [
  httpoison_options: [proxy: "my.proxy.server:3128", proxy_auth: {"username", "password"}]
]
```

Set default provider:

```elixir
config :geocoder, :worker, [
  provider: Geocoder.GoogleMaps # or OpenStreetMaps
]
```

Let's rumble!

Usage
-----

```elixir
# query data
Geocoder.call("Toronto, ON")
Geocoder.call({43.653226, -79.383184})
Geocoder.call({43.653226, -79.383184}, provider: Geocoder.OpenStreetMaps)

# query and set provider
{:ok, provider} = Geocoder.Worker.provider!(Geocoder.Providers.OpenStreetMaps)
# assert provider == Geocoder.GoogleMaps # returned the previous value
{:ok, provider} = Geocoder.Worker.provider?
# assert provider == Geocoder.Providers.OpenStreetMaps
```

You can pass options to the function that will be passed to the geocoder provider, for example:

```elixir
Geocoder.call(address: "Toronto, ON", language: "es", key: "...", ...)
```

See [here](https://developers.google.com/maps/documentation/geocoding/intro#geocoding) and [here](https://developers.google.com/maps/documentation/geocoding/intro#ReverseGeocoding) for a list of supported parameters for the default geocoder provider (`Geocoder.GoogleMaps`). Basically this options are fine for _all_ available
providers, because they are used through the protocol they implement.

And you're done! How simple was that?


Changelog
---------

- **0.7.0**
  - multiple providers are supported through `protocol`;
  - the provider might be explicitly specified in call to `Geocoder.call`;
  - the provider might be changed globally through call to `Geocoder.Worker.provider!`;
  - the data returned by `Geocoder.call` is the structure, that implements a
    standard protocol `Geocoder.Data` and stores all the possible values.
