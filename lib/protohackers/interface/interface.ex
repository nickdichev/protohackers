defmodule Protohackers.Interface do
  use Supervisor

  alias Protohackers.Interface.Ranch

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    children = [
      {Protohackers.RanchListener, protocol: Ranch.SmokeTest, port: 5555},
      {Protohackers.RanchListener, protocol: Ranch.PrimeTime, port: 5556},
      {Protohackers.RanchListener, protocol: Ranch.MeansToEnd, port: 5557}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
