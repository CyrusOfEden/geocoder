defmodule Geocoder.Worker do
  use GenServer
  use Towel

  # Public API
  def geocode(q, opts \\ []) do
    geocode_list(q, opts) |> head
  end

  def geocode_list(q, opts \\ []) do
    assign(:geocode, q, opts) |> tail
  end

  def reverse_geocode(q, opts \\ []) do
    reverse_geocode_list(q, opts) |> head
  end

  def reverse_geocode_list(q, opts \\ []) do
    assign(:reverse_geocode, q, opts) |> tail
  end

  @doc """
    Changes the default provider on the fly.

    Accepts both the module, representing provider or an instance of struct.

    Currently supported protocols:
    - `Geocoder.GoogleMaps`
    - `Geocoder.Providers.OpenStreetMaps`
  """
  def provider!(provider) do
    cast_to = case provider do
      Geocoder.GoogleMaps -> provider
      Geocoder.Providers.OpenStreetMaps -> provider
      _ -> case Geocoder.Data.impl_for(provider) do
             Geocoder.Data.Geocoder.GoogleMaps -> Geocoder.GoogleMaps
             Geocoder.Data.Geocoder.Providers.OpenStreetMaps -> Geocoder.Providers.OpenStreetMaps
             _ -> raise ArgumentError, message: "Provider must implement Geocoder.Data protocol: #{inspect(provider)}"
           end
    end
    assign(:set_provider, [cast_to], store: false)
  end

  @doc """
    Returns current provider.
  """
  def provider? do
    assign(:get_provider, nil, store: false)
  end

  # GenServer API
  @worker_defaults [
    store: Geocoder.Store,
    provider: Geocoder.GoogleMaps # OpenStreetMaps
  ]
  def init(conf) do
    {:ok, Keyword.merge(@worker_defaults, conf)}
  end

  def start_link(conf) do
    GenServer.start_link(__MODULE__, conf)
  end

  def handle_call({:set_provider, [provider], _opts}, _from, conf) do
    {:reply, {:ok, conf[:provider]}, conf |> put_in([:provider], provider)}
  end

  def handle_call({:get_provider, _stub, _opts}, _from, conf) do
    {:reply, {:ok, conf[:provider]}, conf}
  end

  def handle_call({function, q, opts}, _from, conf) do
    {:reply, run(function, q, conf, opts[:store]), conf}
  end

  def handle_cast({function, q, opts}, conf) do
    Task.start_link fn ->
      send(opts[:stream_to], run(function, conf, q, opts[:store]))
    end
    {:noreply, conf}
  end

  # Private API
  @assign_defaults [
    timeout: 5000,
    stream_to: nil,
    store: true
  ]

  defp assign(name, q, opts) do
    opts = Keyword.merge(@assign_defaults, opts)

    function = case {opts[:stream_to], {name, q, opts}} do
      {nil, message} -> &GenServer.call(&1, message, opts[:timeout])
      {_,   message} -> &GenServer.cast(&1, message)
    end

    :poolboy.transaction(Geocoder.pool_name, function, opts[:timeout])
  end

  defp run(function, conf, q, false) do
    {q, params} = {q[:address] || q[:latlng] || q, Geocoder.QueryParams.new(q)}
    Geocoder.Providers.Provider.go!(q, params, conf[:provider])
      |> tap(&conf[:store].update/1)
      |> tap(&conf[:store].link(q, &1))
  end

  defp run(function, q, conf, true) do
    case apply(conf[:store], function, [q]) do
      {:just, coords} ->
        ok(coords)
      :nothing ->
        run(function, conf, q, false)
    end
  end

  defp head({:ok, [data|_]}), do: {:ok, data}
  defp head({:ok, data}), do: {:ok, data}
  defp head(data), do: data

  defp tail({:ok, data}) when is_list(data), do: {:ok, data}
  defp tail({:ok, data}), do: {:ok, [data]}
  defp tail(data), do: data
end
