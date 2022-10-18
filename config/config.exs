import Config

config :geocoder, :worker_pool_config,
  size: 4,
  max_overflow: 2

config :geocoder, Geocoder.Worker,
  data: %{
    ~r/.*Troy, NY.*/ => %{
      lat: 0.0,
      lon: 0.0,
      bounds: %{
        top: 0.0,
        right: 0.0,
        bottom: 0.0,
        left: 0.0
      },
      location: %{
        street_number: "1991",
        street: "15th Street",
        city: "Troy",
        county: "Rensselaer County",
        country_code: "us",
        postal_code: "12180"
      }
    },
    ~r/.*Wondelgem, Belgium.*/ => %{
      lat: 51.0775527,
      lon: 3.7074204,
      bounds: %{
        bottom: 51.077496,
        left: 3.7073144,
        right: 3.7075457,
        top: 51.0776028
      },
      location: %{
        city: "Ghent",
        country: "Belgium",
        country_code: "be",
        county: "Gent",
        formatted_address: "Dikkelindestraat 46, 9032 Ghent, Belgium",
        postal_code: "9032",
        state: "East Flanders",
        street: "Dikkelindestraat",
        street_number: "46"
      }
    },
    {51.0775264, 3.7073382} => %{
      lat: 51.0775527,
      lon: 3.7074204,
      bounds: %{
        bottom: 51.077496,
        left: 3.7073144,
        right: 3.7075457,
        top: 51.0776028
      },
      location: %{
        city: "Ghent",
        country: "Belgium",
        country_code: "be",
        county: "Gent",
        formatted_address: "Dikkelindestraat 46, 9032 Ghent, Belgium",
        postal_code: "9032",
        state: "East Flanders",
        street: "Dikkelindestraat",
        street_number: "46"
      }
    },
    ~r/.*São Paulo, Brazil.*/ => %{
      lat: -23.473875,
      lon: -46.6088782,
      bounds: %{
        bottom: nil,
        left: nil,
        right: nil,
        top: nil
      },
      location: %{
        city: nil,
        country: "Brazil",
        country_code: "BR",
        county: "São Paulo",
        formatted_address: "Travessa Mário Antônio Correia, 80 - Tucuruvi, São Paulo - SP, 02342-170, Brazil",
        postal_code: "02342-170",
        state: "São Paulo",
        street: "Travessa Mário Antônio Correia",
        street_number: "80"
      },
      partial_match: true
    }
  }

case System.get_env("PROVIDER", "fake") do
  "google" ->
    config :geocoder, :worker,
      provider: Geocoder.Providers.GoogleMaps,
      key: System.get_env("API_KEY", "NO_API_KEY")

  "opencagedata" ->
    config :geocoder, :worker,
      provider: Geocoder.Providers.OpenCageData,
      key: System.get_env("API_KEY", "NO_API_KEY")

  "openstreetmaps" ->
    config :geocoder, :worker, provider: Geocoder.Providers.OpenStreetMaps

  "fake" ->
    config :geocoder, :worker, provider: Geocoder.Providers.Fake
end
