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
  [{:geocoder, "~> 0.3"}]
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
config :geocoder, :worker_pool_config, [
  size: 4,
  max_overflow: 2
]
```

Let's rumble!

Usage
-----

```elixir
Geocoder.call("Toronto, ON")
Geocoder.call({43.653226, -79.383184})
```

And you're done! How simple was that?
