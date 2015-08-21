Geocoder
========

Add to your deps, add it to the list of applications.

```elixir
Geocoder.geocode("Toronto, ON")
Geocoder.reverse_geocode({43.653226, -79.383184})

# Or use Geocoder.call, which calls the above depending on
# whether a string was passed in or a 2-tuple
```
