defprotocol Geocoder.Request do
  @doc """
    The region code, specified as a ccTLD ("top-level domain") two-character value.
    This parameter will only influence, not fully restrict, results from the geocoder.
    (For more information see Region Biasing below.)

    @tags [direct]
  """
  def region(data)

  @doc """
    One or more location types

    @tags [reverse]
  """

  @doc """
    Specifying a type will restrict the results to this type.

    If multiple types are specified, the API will return all addresses
    that match any of the types.

    _Note:_ This parameter is available only for requests that include an API key or a client ID.

    The following values are supported:
      - `"ROOFTOP"` restricts the results to addresses for which we have location
        information accurate down to street address precision.
      - `"RANGE_INTERPOLATED"` restricts the results to those that reflect
        an approximation (usually on a road) interpolated between two precise points
        (such as intersections).
        An interpolated range generally indicates that rooftop geocodes are unavailable for a street address.
      - `"GEOMETRIC_CENTER"` restricts the results to geometric centers
        of a location such as a polyline (for example, a street) or polygon (region).
      - `"APPROXIMATE"` restricts the results to those that are characterized as approximate.

    If both `result_type` and `location_type` restrictions are present
    then the API will return only those results that matches
    both the `result_type` and the `location_type` restrictions.
  """
  def location_type(data)
  @doc """
    Your application's API key. This key identifies your application
    for purposes of quota management.
    Learn [how to get a key](https://developers.google.com/maps/documentation/geocoding/get-api-key).

    _Note:_ **valid for commercial providers only, e.g. `Google`.
    Google Maps APIs Premium Plan customers may use either an API key,
    or a valid client ID and digital signature, in your Geocoding requests.
    Get more information on authentication parameters for Premium Plan customers.

    @tags [direct, reverse]
  """
  def key(data)

  ##############################################################################

  @doc """
    The language in which to return results.

    @tags [direct, reverse]
  """
  @doc """
    See the [list of supported languages](https://developers.google.com/maps/faq#languagesupport).
    Google often updates the supported languages, so this list may not be exhaustive.
    If language is not supplied, the geocoder attempts to use the preferred language
    as specified in the Accept-Language header, or the native language
    of the domain from which the request is sent.

    The geocoder does its best to provide a street address that is readable for both
    the user and locals. To achieve that goal, it returns street addresses in the local language,
    transliterated to a script readable by the user if necessary, observing the preferred language.
    All other addresses are returned in the preferred language.

    Address components are all returned in the same language, which is chosen from the first component.
    If a name is not available in the preferred language, the geocoder uses the closest match.
    The preferred language has a small influence on the set of results that the API chooses to return,
    and the order in which they are returned.
    The geocoder interprets abbreviations differently depending on language, such as the abbreviations
    for street types, or synonyms that may be valid in one language but not in another.
    For example, utca and tér are synonyms for street in Hungarian.
  """
  def language(data)
end
