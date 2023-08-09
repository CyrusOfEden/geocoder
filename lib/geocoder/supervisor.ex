defmodule Geocoder.Supervisor do
  @moduledoc """
  Supervisor for the Geocoder Worker pool and Geocoder Store. See `Geocoder.Config` for details
  on the configurations and the possible values

  ### Configuration Example to use a different provider (google)

  ```elixir
    Supervisor.start_link(worker_config: [provider: Geocoder.Providers.Google])
  ```

  ### Configuration Example to use a different HttpClient

  ```elixir
    Supervisor.start_link(worker_config: [http_client: MyApp.MyClient, http_client_opts: [timeout: 1]])
  ```
  """

  use Supervisor

  alias Geocoder.Config

  @spec start_link(Keyword.t()) :: Supervisor.on_start()
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Supervisor
  def init(opts) do
    config = Config.all(opts)

    children = [
      :poolboy.child_spec(
        config[:pool_name],
        config[:pool_config],
        config
      ),
      {config[:store_module], config[:store_config]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
