defmodule Protohackers.RanchListener do
  def child_spec(opts) do
    {protocol, opts} = Keyword.pop!(opts, :protocol)
    ref = Module.split(protocol) |> List.last() |> then(&Module.concat(__MODULE__, &1))

    :ranch.child_spec(ref, :ranch_tcp, opts, protocol, [])
  end
end
