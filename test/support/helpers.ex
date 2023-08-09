defmodule Geocoder.Support.Helpers do
  @moduledoc """
  a set of assertion or configuration helpers to avoid cluttering the tests
  """
  import ExUnit.Assertions

  def assert_belgium(%{bounds: bounds, location: location, lat: lat, lon: lon}) do
    # Bounds are not always returned
    assert nil == bounds.bottom || bounds.bottom |> Float.round(2) == 51.08
    assert nil == bounds.left || bounds.left |> Float.round(2) == 3.71
    assert nil == bounds.right || bounds.right |> Float.round(2) == 3.71
    assert nil == bounds.top || bounds.top |> Float.round(2) == 51.08

    assert nil == location.street_number || location.street_number == "46"
    assert location.street == "Dikkelindestraat"
    assert location.city == "Gent" || location.city == "Ghent"
    assert location.country == "Belgium"
    assert location.country_code |> String.upcase() == "BE"
    assert location.postal_code == "9032"
    # lhs:  "Dikkelindestraat, Wondelgem, Ghent, Gent, East Flanders, Flanders, 9032, Belgium"
    # rhs:  "Dikkelindestraat 46, 9032 Gent, Belgium"
    assert location.formatted_address |> String.match?(~r/Dikkelindestraat/)

    assert location.formatted_address |> String.match?(~r/Gent/) ||
             location.formatted_address |> String.match?(~r/Ghent/)

    assert location.formatted_address |> String.match?(~r/9032/)
    assert location.formatted_address |> String.match?(~r/Belgium/)
    assert lat |> Float.round(2) == 51.08
    assert lon |> Float.round(2) == 3.71
  end

  def assert_new_york(%Geocoder.Coords{location: location}) do
    assert location.street_number == "1991"
    assert location.street == "15th Street"
    assert String.contains?(location.city, "Troy")
    assert location.county == "Rensselaer County"
    assert location.country_code |> String.upcase() == "US"
    assert location.postal_code == "12180"
  end

  def assert_sao_paulo(%{location: location, partial_match: partial_match}) do
    assert location.country == "Brazil"
    assert location.country_code |> String.upcase() == "BR"
    assert location.county == "São Paulo"

    assert location.formatted_address ==
             "Travessa Mário Antônio Correia, 80 - Tucuruvi, São Paulo - SP, 02342-170, Brazil"

    assert location.postal_code == "02342-170"
    assert location.street == "Travessa Mário Antônio Correia"
    assert location.street_number == "80"
    assert partial_match == true
  end

  def belgium_openstreetmap_payload do
    %{
      "address" => %{
        "city" => "Ghent",
        "city_district" => "Wondelgem",
        "country" => "Belgium",
        "country_code" => "be",
        "county" => "Gent",
        "postcode" => "9032",
        "road" => "Dikkelindestraat",
        "state" => "Flanders"
      },
      "boundingbox" => ["51.075731", "51.0786674", "3.7063849", "3.7083991"],
      "display_name" =>
        "Dikkelindestraat, Wondelgem, Ghent, Gent, East Flanders, Flanders, 9032, Belgium",
      "lat" => "51.0772661",
      "licence" =>
        "Data © OpenStreetMap contributors, ODbL 1.0. http://www.openstreetmap.org/copyright",
      "lon" => "3.7074267",
      "osm_id" => "45352282",
      "osm_type" => "way",
      "place_id" => "70350383"
    }
  end

  def belgium_coords do
    %Geocoder.Coords{
      lat: 51.0772661,
      lon: 3.7074267,
      bounds: %Geocoder.Bounds{
        top: 51.075731,
        right: 3.7083991,
        bottom: 51.0786674,
        left: 3.7063849
      },
      location: %Geocoder.Location{
        city: "Ghent",
        state: "Flanders",
        county: "Gent",
        country: "Belgium",
        postal_code: "9032",
        street: "Dikkelindestraat",
        street_number: nil,
        country_code: "be",
        formatted_address:
          "Dikkelindestraat, Wondelgem, Ghent, Gent, East Flanders, Flanders, 9032, Belgium"
      },
      partial_match: nil
    }
  end

  def fake_data_cache do
    %{
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
          formatted_address:
            "Travessa Mário Antônio Correia, 80 - Tucuruvi, São Paulo - SP, 02342-170, Brazil",
          postal_code: "02342-170",
          state: "São Paulo",
          street: "Travessa Mário Antônio Correia",
          street_number: "80"
        },
        partial_match: true
      }
    }
  end

  def provider_test_config(provider, key) do
    case provider do
      "google" ->
        [
          worker_config: [
            provider: Geocoder.Providers.GoogleMaps,
            key: key,
            http_client: Geocoder.HttpClient.Hackney
          ]
        ]

      "opencagedata" ->
        [
          worker_config: [
            provider: Geocoder.Providers.OpenCageData,
            key: key
          ]
        ]

      "openstreetmaps" ->
        [
          worker_config: [
            provider: Geocoder.Providers.OpenStreetMaps
          ]
        ]

      "fake" ->
        [
          worker_config: [
            provider: Geocoder.Providers.Fake,
            data: fake_data_cache()
          ]
        ]

      _ ->
        raise "Unsupported provider. Must be one of: google, opencagedata, openstreetmaps or fake. Default is fake"
    end
  end

  def belgium_googlemap_payload do
    %{
      "results" => [
        %{
          "address_components" => [
            %{
              "long_name" => "46",
              "short_name" => "46",
              "types" => ["street_number"]
            },
            %{
              "long_name" => "Dikkelindestraat",
              "short_name" => "Dikkelindestraat",
              "types" => ["route"]
            },
            %{
              "long_name" => "Gent",
              "short_name" => "Gent",
              "types" => ["locality", "political"]
            },
            %{
              "long_name" => "Oost-Vlaanderen",
              "short_name" => "OV",
              "types" => ["administrative_area_level_2", "political"]
            },
            %{
              "long_name" => "Vlaams Gewest",
              "short_name" => "Vlaams Gewest",
              "types" => ["administrative_area_level_1", "political"]
            },
            %{
              "long_name" => "Belgium",
              "short_name" => "BE",
              "types" => ["country", "political"]
            },
            %{
              "long_name" => "9032",
              "short_name" => "9032",
              "types" => ["postal_code"]
            }
          ],
          "formatted_address" => "Dikkelindestraat 46, 9032 Gent, Belgium",
          "geometry" => %{
            "location" => %{"lat" => 51.0775297, "lng" => 3.70734},
            "location_type" => "ROOFTOP",
            "viewport" => %{
              "northeast" => %{
                "lat" => 51.0788726802915,
                "lng" => 3.708676980291502
              },
              "southwest" => %{
                "lat" => 51.0761747197085,
                "lng" => 3.705979019708498
              }
            }
          },
          "place_id" => "ChIJNVeLFB1xw0cRxjH2l4f2aCg",
          "plus_code" => %{
            "compound_code" => "3PH4+2W Ghent, Belgium",
            "global_code" => "9F353PH4+2W"
          },
          "types" => ["street_address"]
        }
      ],
      "status" => "OK"
    }
  end

  def belgium_opencagedata_payload do
    %{
      "documentation" => "https://opencagedata.com/api",
      "licenses" => [
        %{
          "name" => "see attribution guide",
          "url" => "https://opencagedata.com/credits"
        }
      ],
      "rate" => %{"limit" => 2500, "remaining" => 2494, "reset" => 1_691_625_600},
      "results" => [
        %{
          "annotations" => %{
            "DMS" => %{
              "lat" => "51° 4' 39.18972'' N",
              "lng" => "3° 42' 26.71344'' E"
            },
            "MGRS" => "31UES4955658687",
            "Maidenhead" => "JO11ub48vo",
            "Mercator" => %{"x" => 412_708.149, "y" => 6_601_759.73},
            "NUTS" => %{
              "NUTS0" => %{"code" => "BE"},
              "NUTS1" => %{"code" => "BE2"},
              "NUTS2" => %{"code" => "BE23"},
              "NUTS3" => %{"code" => "BE234"}
            },
            "OSM" => %{
              "edit_url" =>
                "https://www.openstreetmap.org/edit?way=629451771#map=16/51.07755/3.70742",
              "note_url" =>
                "https://www.openstreetmap.org/note/new#map=16/51.07755/3.70742&layers=N",
              "url" =>
                "https://www.openstreetmap.org/?mlat=51.07755&mlon=3.70742#map=16/51.07755/3.70742"
            },
            "UN_M49" => %{
              "regions" => %{
                "BE" => "056",
                "EUROPE" => "150",
                "WESTERN_EUROPE" => "155",
                "WORLD" => "001"
              },
              "statistical_groupings" => ["MEDC"]
            },
            "callingcode" => 32,
            "currency" => %{
              "alternate_symbols" => [],
              "decimal_mark" => ",",
              "html_entity" => "€",
              "iso_code" => "EUR",
              "iso_numeric" => "978",
              "name" => "Euro",
              "smallest_denomination" => 1,
              "subunit" => "Cent",
              "subunit_to_unit" => 100,
              "symbol" => "€",
              "symbol_first" => 0,
              "thousands_separator" => "."
            },
            "flag" => "🇧🇪",
            "geohash" => "u14ds67sm1vj8nspqj3z",
            "qibla" => 122.94,
            "roadinfo" => %{
              "drive_on" => "right",
              "road" => "Dikkelindestraat",
              "speed_in" => "km/h"
            },
            "sun" => %{
              "rise" => %{
                "apparent" => 1_691_554_980,
                "astronomical" => 1_691_545_980,
                "civil" => 1_691_552_700,
                "nautical" => 1_691_549_700
              },
              "set" => %{
                "apparent" => 1_691_608_620,
                "astronomical" => 1_691_617_560,
                "civil" => 1_691_610_900,
                "nautical" => 1_691_613_900
              }
            },
            "timezone" => %{
              "name" => "Europe/Brussels",
              "now_in_dst" => 1,
              "offset_sec" => 7200,
              "offset_string" => "+0200",
              "short_name" => "CEST"
            },
            "what3words" => %{"words" => "energetic.mildest.smashes"}
          },
          "bounds" => %{
            "northeast" => %{"lat" => 51.0776028, "lng" => 3.7075457},
            "southwest" => %{"lat" => 51.077496, "lng" => 3.7073144}
          },
          "components" => %{
            "ISO_3166-1_alpha-2" => "BE",
            "ISO_3166-1_alpha-3" => "BEL",
            "ISO_3166-2" => ["BE-VLG", "BE-VOV"],
            "_category" => "building",
            "_type" => "building",
            "city" => "Ghent",
            "city_district" => "Ghent",
            "continent" => "Europe",
            "country" => "Belgium",
            "country_code" => "be",
            "county" => "Gent",
            "house_number" => "46",
            "political_union" => "European Union",
            "postcode" => "9032",
            "region" => "Flanders",
            "road" => "Dikkelindestraat",
            "state" => "East Flanders",
            "state_code" => "VOV"
          },
          "confidence" => 10,
          "formatted" => "Dikkelindestraat 46, 9032 Ghent, Belgium",
          "geometry" => %{"lat" => 51.0775527, "lng" => 3.7074204}
        },
        %{
          "annotations" => %{
            "DMS" => %{
              "lat" => "51° 2' 60.00000'' N",
              "lng" => "3° 43' 0.12000'' E"
            },
            "MGRS" => "31UES5023655629",
            "Maidenhead" => "JO11ub62aa",
            "Mercator" => %{"x" => 413_741.151, "y" => 6_596_892.23},
            "NUTS" => %{
              "NUTS0" => %{"code" => "BE"},
              "NUTS1" => %{"code" => "BE2"},
              "NUTS2" => %{"code" => "BE23"},
              "NUTS3" => %{"code" => "BE234"}
            },
            "OSM" => %{
              "note_url" =>
                "https://www.openstreetmap.org/note/new#map=16/51.05000/3.71670&layers=N",
              "url" =>
                "https://www.openstreetmap.org/?mlat=51.05000&mlon=3.71670#map=16/51.05000/3.71670"
            },
            "UN_M49" => %{
              "regions" => %{
                "BE" => "056",
                "EUROPE" => "150",
                "WESTERN_EUROPE" => "155",
                "WORLD" => "001"
              },
              "statistical_groupings" => ["MEDC"]
            },
            "callingcode" => 32,
            "currency" => %{
              "alternate_symbols" => [],
              "decimal_mark" => ",",
              "html_entity" => "€",
              "iso_code" => "EUR",
              "iso_numeric" => "978",
              "name" => "Euro",
              "smallest_denomination" => 1,
              "subunit" => "Cent",
              "subunit_to_unit" => 100,
              "symbol" => "€",
              "symbol_first" => 0,
              "thousands_separator" => "."
            },
            "flag" => "🇧🇪",
            "geohash" => "u14dkt67v3sru2h30u2v",
            "qibla" => 122.93,
            "roadinfo" => %{"drive_on" => "right", "speed_in" => "km/h"},
            "sun" => %{
              "rise" => %{
                "apparent" => 1_691_554_980,
                "astronomical" => 1_691_545_980,
                "civil" => 1_691_552_700,
                "nautical" => 1_691_549_700
              },
              "set" => %{
                "apparent" => 1_691_608_620,
                "astronomical" => 1_691_617_560,
                "civil" => 1_691_610_900,
                "nautical" => 1_691_613_840
              }
            },
            "timezone" => %{
              "name" => "Europe/Brussels",
              "now_in_dst" => 1,
              "offset_sec" => 7200,
              "offset_string" => "+0200",
              "short_name" => "CEST"
            },
            "what3words" => %{"words" => "silver.staked.evidently"}
          },
          "components" => %{
            "ISO_3166-1_alpha-2" => "BE",
            "ISO_3166-1_alpha-3" => "BEL",
            "_category" => "postcode",
            "_type" => "postcode",
            "continent" => "Europe",
            "country" => "Belgium",
            "country_code" => "be",
            "political_union" => "European Union",
            "postcode" => "9032",
            "state" => "Flanders"
          },
          "confidence" => 7,
          "formatted" => "9032 Flanders, Belgium",
          "geometry" => %{"lat" => 51.05, "lng" => 3.7167}
        }
      ],
      "status" => %{"code" => 200, "message" => "OK"},
      "stay_informed" => %{
        "blog" => "https://blog.opencagedata.com",
        "mastodon" => "https://en.osm.town/@opencage"
      },
      "thanks" => "For using an OpenCage API",
      "timestamp" => %{
        "created_http" => "Wed, 09 Aug 2023 17:21:25 GMT",
        "created_unix" => 1_691_601_685
      },
      "total_results" => 2
    }
  end
end
