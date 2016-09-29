defmodule Geocoder.Worker do
  use GenServer
  use Towel

  # Public API
  def geocode(q, opts \\ []) do
    assign(:geocode, q, opts)
  end

  def geocode_list(q, opts \\ []) do
    assign(:geocode_list, q, opts)
  end

  def reverse_geocode(q, opts \\ []) do
    assign(:reverse_geocode, q, opts)
  end

  def reverse_geocode_list(q, opts \\ []) do
    assign(:reverse_geocode_list, q, opts)
  end

  @doc """
    Changes the default provider on the fly.

    Accepts both the module, representing provider or an instance of struct.

    Currently supported protocols:
    - `Geocoder.Providers.GoogleMaps`
    - `Geocoder.Providers.OpenStreetMaps`
  """
  def provider!(provider) do
    cast_to = case provider do
      Geocoder.Providers.GoogleMaps -> provider
      Geocoder.Providers.OpenStreetMaps -> provider
      _ -> case Geocoder.Data.impl_for(provider) do
             nil -> raise ArgumentError, message: "Provider must implement Geocoder.ProviderProtocol: #{inspect(provider)}"
             impl -> impl
           end
    end
    GenServer.call(__MODULE__, {:set_provider, cast_to})
  end
  @doc """
    Returns current provider.
  """
  def provider? do
    GenServer.call(__MODULE__, {:get_provider, []})
  end

  # GenServer API
  @worker_defaults [
    store: Geocoder.Store,
    provider: Geocoder.Providers.GoogleMaps # OpenStreetMaps
  ]
  def init(conf) do
    {:ok, Keyword.merge(@worker_defaults, conf)}
  end

  def start_link(conf) do
    GenServer.start_link(__MODULE__, conf)
  end

  def handle_call({:set_provider, provider}, _from, conf) do
    conf = conf |> update_in(:provider, provider)
    {:reply, {:ok, provider}, conf}
  end

  def handle_call({:get_provider, _opts}, _from, conf) do
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

  defp run(function, q, conf, _) when function == :geocode_list or function == :reverse_geocode_list do
    apply(conf[:provider], function, [q])
  end
  defp run(function, conf, q, false) do
    # apply(conf[:provider], function, [q])
    Geocoder.Providers.Provider.go!(q, %Geocoder.QueryParams{}, conf[:provider])
    # |> tap(&conf[:store].update/1)
    # |> tap(&conf[:store].link(q, &1))
  end
  defp run(function, q, conf, true) do
    case apply(conf[:store], function, [q]) do
      {:just, coords} ->
        ok(coords)
      :nothing ->
        run(function, conf, q, false)
    end
  end
end
