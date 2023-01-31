defmodule Protohackers.Protocols.MeansToEnd do
  use GenServer

  alias Protohackers.Protocols.MeansToEnd.Response
  alias Protohackers.Protocols.MeansToEnd.Request

  @behaviour :ranch_protocol
  @timeout 60_000

  require Logger

  @impl :ranch_protocol
  def start_link(ref, transport, opts) do
    GenServer.start_link(__MODULE__, {ref, transport, opts}, timeout: @timeout)
  end

  @impl GenServer
  def init(initial_state = {_ref, _transport, _opts}) do
    {:ok, initial_state, {:continue, :handshake}}
  end

  @impl GenServer
  def handle_continue(:handshake, {ref, transport, _opts}) do
    {:ok, socket} = :ranch.handshake(ref)
    :ok = transport.setopts(socket, active: true)

    state = %{socket: socket, transport: transport, prices: []}

    {:noreply, state, @timeout}
  end

  @impl GenServer
  def handle_info({:tcp, socket, data}, state) do
    %{socket: _socket, transport: transport, prices: prices} = state

    case Request.parse_request(data) do
      {:insert, %{timestamp: timestamp, price: price}} ->
        state = %{state | prices: [{timestamp, price} | prices]}
        {:noreply, state, @timeout}

      {:query, %{min_time: min_time, max_time: max_time}} when min_time > max_time ->
        :ok = transport.send(socket, <<0::big-signed-32>>)
        {:noreply, state, @timeout}

      {:query, %{min_time: min_time, max_time: max_time}} ->
        if Enum.empty?(prices) do
          :ok = transport.send(socket, <<0::big-signed-32>>)
          {:noreply, state, @timeout}
        else
          count = length(prices)

          sum =
            prices
            |> Enum.filter(fn {timestamp, _price} ->
              timestamp >= min_time and timestamp <= max_time
            end)
            |> Enum.map(fn {_timestamp, price} -> price end)
            |> Enum.sum()

          average = (sum / count) |> IO.inspect() |> floor()

          :ok = transport.send(socket, <<average::big-signed-32>>)
          {:noreply, state, @timeout}
        end
    end
  end

  @impl GenServer
  def handle_info({:tcp_closed, _port}, {socket, transport} = state) do
    transport.close(socket)
    {:stop, :shutdown, state}
  end
end
