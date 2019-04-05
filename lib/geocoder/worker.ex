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

  # GenServer API
  @worker_defaults [
    store: Geocoder.Store,
    # or OpenStreetMaps
    provider: Geocoder.Providers.GoogleMaps
  ]
  def init(conf) do
    {:ok, Keyword.merge(@worker_defaults, conf)}
  end

  def start_link(conf) do
    GenServer.start_link(__MODULE__, conf)
  end

  def handle_call({function, q, opts}, _from, conf) do
    {:reply, run(function, q, conf, opts[:store]), conf}
  end

  def handle_cast({function, q, opts}, conf) do
    Task.start_link(fn ->
      send(opts[:stream_to], run(function, conf, q, opts[:store]))
    end)

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

    function =
      case {opts[:stream_to], {name, q, opts}} do
        {nil, message} -> &GenServer.call(&1, message, opts[:timeout])
        {_, message} -> &GenServer.cast(&1, message)
      end

    :poolboy.transaction(Geocoder.pool_name(), function, opts[:timeout])
  end

  def run(function, q, conf, _) when function in [:geocode_list, :reverse_geocode_list] do
    apply(conf[:provider], function, [additionnal_conf(q, conf)])
  end

  def run(function, conf, q, false) do
    apply(conf[:provider], function, [additionnal_conf(q, conf)])
    |> tap(&conf[:store].update/1)
    |> tap(&conf[:store].link(q, &1))
  end

  def run(function, q, conf, true) do
    case apply(conf[:store], function, [additionnal_conf(q, conf)]) do
      {:just, coords} ->
        ok(coords)

      :nothing ->
        run(function, conf, q, false)
    end
  end

  def additionnal_conf(q, conf) do
    Keyword.merge(q, Keyword.drop(conf, [:store, :provider]))
  end
end
