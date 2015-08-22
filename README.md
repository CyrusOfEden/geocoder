Geocoder
========

A simple, efficient geocoder/reverse geocoder with a built-in cache.

Is it extensible? Yes.
**Is it any good?** Absolutely.

Installation
------------

Keep calm and add Geocoder to your `mix.exs` dependencies:

```elixir
def deps do
  [{:geocoder, "~> 0.2"}]
end
```

Add it to your starting applications too:

```elixir
def application do
  [applications: [:logger, :geocoder]]
end
```

Let's rumble!

Usage
-----

```elixir
Geocoder.geocode("Toronto, ON")
Geocoder.reverse_geocode({43.653226, -79.383184})

# Or use Geocoder.call, which calls the above depending on
# whether a string was passed in or a 2-tuple
```

And you're done! How simple was that?

_Note:_ It is possible to switch out Geocoder's built-in store or the default provider (currently Google Maps) by passing in different arguments to `Geocoder.start`, but those docs will come later. The store/provider must implement a specific API.
