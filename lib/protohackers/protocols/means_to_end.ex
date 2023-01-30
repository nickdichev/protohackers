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
    :ok = transport.setopts(socket, active: false)

    {:noreply, {socket, transport}, {:continue, :loop}}
  end

  @impl GenServer
  def handle_continue(:loop, state) do
    {socket, transport} = state

    {:ok, request} = transport.recv(socket, _length = 9, :infinity)

    case Request.parse_request(request) do
      {:insert, %{timestamp: timestamp, price: price}} ->
        :ok

      {:query, %{min_time: min_time, max_time: max_time}} ->
        :ok
    end

    :ok = transport.send(socket, "booo!")
    {:noreply, state, {:continue, :loop}}
  end

  @impl GenServer
  def handle_info({:tcp_closed, _port}, {socket, transport} = state) do
    transport.close(socket)
    {:stop, :shutdown, state}
  end
end
