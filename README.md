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
  [{:geocoder, "~> 0.4"}]
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

Let's rumble!

Usage
-----

```elixir
Geocoder.call("Toronto, ON")
Geocoder.call({43.653226, -79.383184})
```

You can pass options to the function that will be passed to the geocoder provider, for example:

```elixir
Geocoder.call(address: "Toronto, ON", language: "es", key: "...", ...)
```

See [here](https://developers.google.com/maps/documentation/geocoding/intro#geocoding) and [here](https://developers.google.com/maps/documentation/geocoding/intro#ReverseGeocoding) for a list of supported parameters for the default geocoder provider (`Geocoder.Provider.GoogleMaps`).

And you're done! How simple was that?
