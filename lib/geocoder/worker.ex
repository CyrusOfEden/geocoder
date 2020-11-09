defmodule Geocoder.Worker do
  use GenServer
  use Towel

  # Public API
  def geocode(params) do
    assign(:geocode, params)
  end

  def geocode_list(params) do
    assign(:geocode_list, params)
  end

  def reverse_geocode(params) do
    assign(:reverse_geocode, params)
  end

  def reverse_geocode_list(params) do
    assign(:reverse_geocode_list, params)
  end

  # GenServer API
  @worker_defaults [
    store: Geocoder.Store,
    provider: Geocoder.Providers.OpenStreetMaps
  ]
  def init(conf) do
    {:ok, Keyword.merge(@worker_defaults, conf)}
  end

  def start_link(conf) do
    GenServer.start_link(__MODULE__, conf)
  end

  def handle_call({function, params}, _from, conf) do
    # unfortunately, both the worker and param defaults use `store`
    # for the worker, this defines which store to use, for the params
    # this defines if the store should be used
    use_store = params[:store]

    params = Keyword.merge(conf, Keyword.drop(params, [:store]))
    {:reply, run(function, params, use_store), conf}
  end

  def handle_cast({function, params}, conf) do
    Task.start_link(fn ->
      send(params[:stream_to], run(function, params, params[:store]))
    end)

    {:noreply, conf}
  end

  # Private API
  @assign_defaults [
    timeout: 5000,
    stream_to: nil,
    store: true
  ]

  defp assign(name, params) do
    gen_server_options = Keyword.merge(@assign_defaults, params)
    params_with_defaults = Keyword.drop(gen_server_options, [:timeout, :stream_to])

    function =
      case {gen_server_options[:stream_to], {name, params_with_defaults}} do
        {nil, message} -> &GenServer.call(&1, message, gen_server_options[:timeout])
        {_, message} -> &GenServer.cast(&1, message)
      end

    :poolboy.transaction(Geocoder.pool_name(), function, gen_server_options[:timeout])
  end

  def run(function, params, useStore)

  def run(function, params, _) when function in [:geocode_list, :reverse_geocode_list] do
    apply(params[:provider], function, [params])
  end

  def run(function, params, false) do
    apply(params[:provider], function, [params])
    |> tap(&params[:store].update/1)
    |> tap(&params[:store].link(params, &1))
  end

  def run(function, params, true) do
    case apply(params[:store], function, [params]) do
      {:just, coords} ->
        ok(coords)

      :nothing ->
        run(function, params, false)
    end
  end
end
