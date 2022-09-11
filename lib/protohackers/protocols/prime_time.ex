defmodule Protohackers.Protocols.PrimeTime do
  use GenServer

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
    :ok = transport.setopts(socket, active: :once)

    {:noreply, {socket, transport}, @timeout}
  end

  @impl GenServer
  def handle_info({:tcp, socket, data}, {socket, transport} = state) do
    case Protohackers.PrimeTime.handle_request(data) do
      {:ok, response} ->
        :ok = transport.send(socket, response)
        :ok = transport.setopts(socket, active: :once)
        {:noreply, state, @timeout}

      {:error, response} ->
        :ok = transport.send(socket, response)
        transport.close(socket)
        {:stop, :shutdown, state}
    end
  end

  @impl GenServer
  def handle_info({:tcp_closed, _port}, {socket, transport} = state) do
    transport.close(socket)
    {:stop, :shutdown, state}
  end
end
