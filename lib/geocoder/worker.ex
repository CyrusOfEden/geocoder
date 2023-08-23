defmodule Geocoder.Worker do
  @moduledoc """
  Worker the actual process performing the geocoding request to a provider. They are use
  within a pool (using Poolboy. See Supervisor for details)

  Some options are can be passed as part of params such as

    * `:timeout` - The request timeout in milliseconds. Default to 5000 milliseconds
    * `:stream_to` - When specified, an async request will be made and result sent to the value specified.
       It also implies the  HTTP client supports streaming.
    * `:store` - Wether to use the cache store or not. Default to true. So always checking the cache first

  """
  use GenServer

  @default_options [
    timeout: 5000,
    stream_to: nil,
    store: true
  ]

  def geocode(params) do
    {pool_name, params} = Keyword.pop(params, :pool_name)
    assign(pool_name, :geocode, params)
  end

  def geocode_list(params) do
    {pool_name, params} = Keyword.pop(params, :pool_name)

    assign(pool_name, :geocode_list, params)
  end

  def reverse_geocode(params) do
    {pool_name, params} = Keyword.pop(params, :pool_name)

    assign(pool_name, :reverse_geocode, params)
  end

  def reverse_geocode_list(params) do
    {pool_name, params} = Keyword.pop(params, :pool_name)

    assign(pool_name, :reverse_geocode_list, params)
  end

  def init(conf) do
    {:ok, conf}
  end

  def start_link(conf) do
    GenServer.start_link(__MODULE__, conf)
  end

  def handle_call({function, params}, _from, conf) do
    # use to decide wether to check the Store cache or not
    use_store = params[:store]

    params =
      conf
      |> Keyword.take([:store_config, :store_module, :worker_config])
      |> Keyword.merge(params)

    {:reply, run(function, params, use_store), conf}
  end

  def handle_cast({function, params}, conf) do
    Task.start_link(fn ->
      send(params[:stream_to], run(function, params, params[:store]))
    end)

    {:noreply, conf}
  end

  defp assign(pool_name, name, params) do
    gen_server_options = Keyword.merge(@default_options, params)
    params_with_defaults = Keyword.drop(gen_server_options, [:timeout, :stream_to])

    function =
      case {gen_server_options[:stream_to], {name, params_with_defaults}} do
        {nil, message} -> &GenServer.call(&1, message, gen_server_options[:timeout])
        {_, message} -> &GenServer.cast(&1, message)
      end

    :poolboy.transaction(
      pool_name || Geocoder.Config.default_pool_name(),
      function,
      gen_server_options[:timeout]
    )
  end

  defp run(function, params, useStore)

  defp run(function, params, _) when function in [:geocode_list, :reverse_geocode_list] do
    {provider, provider_config, _store_module, _store_name} = get_run_details(params)

    apply(provider, function, [params, provider_config])
  end

  # when the provider is called directly and cache is not attempted
  defp run(function, params, false) do
    {provider, provider_config, store_module, store_name} = get_run_details(params)

    with {:ok, coords} <- apply(provider, function, [params, provider_config]) do
      update_details = store_module.update(store_name, coords)
      store_module.link(store_name, params, update_details)
      {:ok, coords}
    end
  end

  defp run(function, params, true) do
    {_provider, _provider_config, store_module, store_name} = get_run_details(params)

    case apply(store_module, function, [store_name, params]) do
      {:just, coords} ->
        {:ok, coords}

      :nothing ->
        run(function, params, false)
    end
  end

  defp get_run_details(params) do
    # we want to keep any worker_config params that were not overwritten
    worker_config = Geocoder.Config.worker_config(params)
    provider = worker_config[:provider]

    store_module = params[:store_module]
    store_name = params[:store_config][:name]

    provider_config =
      Keyword.take(worker_config, [:http_client, :http_client_opts, :json_codec, :key, :data])

    {provider, provider_config, store_module, store_name}
  end
end
