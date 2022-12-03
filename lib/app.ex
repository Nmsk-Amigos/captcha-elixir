defmodule Agogo.Application do
  use Application
  require Logger

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Agogo.Router, options: [port: 1234]}
    ]
    opts = [strategy: :one_for_one, name: Agogo.Supervisor]

    Logger.info("http://localhost:1234")

    Supervisor.start_link(children, opts)
  end
end
