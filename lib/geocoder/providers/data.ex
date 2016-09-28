defprotocol Geocoder.Data do
  @doc """
    The street address that you want to geocode, in the format used by
    the national postal service of the country concerned.
    Additional address elements such as business names and unit,
    suite or floor numbers should be avoided.
    Please refer to [the FAQ](https://developers.google.com/maps/faq#geocoder_queryformat)
    for additional guidance.

    @tags [direct]
    @see `components`
  """
  def address(data)

  @doc """
    A component filter for which you wish to obtain a geocode.
    See [Component Filtering](https://developers.google.com/maps/documentation/geocoding/intro#ComponentFiltering)
    for more information.

    The components filter will also be accepted as an optional parameter
    if an address is provided.

    @tags [direct]
  """
  @doc """
    The component filters, separated by a pipe (|).
    Each component filter consists of a component:value pair and will fully restrict
    the results from the geocoder.
  """
  def components(data)

  @doc """
    The latitude and longitude values specifying the location
    for which you wish to obtain the closest, human-readable address.

    @tags [reverse]
  """
  def latlng(data)

  @doc """
    The place ID of the place for which you wish to obtain the human-readable address.

    @tags [reverse]
  """
  @doc """
    The place ID is a unique identifier that can be used with other Google APIs.
    For example, you can use the placeID returned by the
    [Google Maps Roads API](https://developers.google.com/maps/documentation/roads/snap)
    to get the address for a snapped point.

    For more information about place IDs, see the
    [place ID overview](https://developers.google.com/places/place-id).
    The place ID may only be specified if the request includes
    an API key or a Google Maps APIs Premium Plan client ID.
  """
  def place_id(data)

  @doc """
    The bounding box of the viewport within which to bias geocode results more prominently.
    This parameter will only influence, not fully restrict, results from the geocoder.
    (For more information see [Viewport Biasing](https://developers.google.com/maps/documentation/geocoding/intro#Viewports).)

    @tags [direct]
  """
  def bounds(data)

  @doc """
    One or more address types.

    @tags [reverse]
  """

  @doc """
    Examples of address types: `country`, `street_address`, `postal_code`.
    For a full list of allowable values,
    see the [address types](https://developers.google.com/maps/documentation/geocoding/intro#Types).

    Specifying a type will restrict the results to this type.
    If multiple types are specified, the API will return all addresses
    that match any of the types.

    _Note:_ This parameter is available only for requests that include an API key or a client ID.

    If both `result_type` and `location_type` restrictions are present
    then the API will return only those results that matches
    both the `result_type` and the `location_type` restrictions.
  """
  def result_type(data)

  @doc """
    Builds a query parameters for the implementation.
  """
  def query(data)

  @doc """
    Specifies the endpoint for the given implementation.
  """
  def endpoint(data, type)
end
