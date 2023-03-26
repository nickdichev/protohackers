defmodule Protohackers.Interface.Ranch.SmokeTest do
  use GenServer

  @behaviour :ranch_protocol
  @timeout 5000

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
    :ok = transport.send(socket, data)
    :ok = transport.setopts(socket, active: :once)
    {:noreply, state, @timeout}
  end

  @impl GenServer
  def handle_info(_, {socket, transport} = state) do
    transport.close(socket)
    {:stop, :shutdown, state}
  end
end
