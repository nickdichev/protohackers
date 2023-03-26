defmodule Protohackers.Interface do
  use Supervisor

  alias Protohackers.Interface

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    children = [
      {ThousandIsland, handler_module: Interface.ThousandIsland.SmokeTest, port: 5555},
      {Protohackers.RanchListener, protocol: Interface.Ranch.PrimeTime, port: 5556},
      {Protohackers.RanchListener, protocol: Interface.Ranch.MeansToEnd, port: 5557}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
