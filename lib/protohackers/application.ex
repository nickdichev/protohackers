defmodule Protohackers.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Protohackers.Listener, protocol: Protohackers.Protocols.SmokeTest, port: 5555},
      {Protohackers.Listener, protocol: Protohackers.Protocols.PrimeTime, port: 5556},
      {Protohackers.Listener, protocol: Protohackers.Protocols.MeansToEnd, port: 5557}
    ]

    opts = [strategy: :one_for_one, name: Protohackers.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
