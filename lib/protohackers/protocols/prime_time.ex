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
    :ok = transport.setopts(socket, active: false)

    {:noreply, {socket, transport}, {:continue, :loop}}
  end

  @impl GenServer
  def handle_continue(:loop, state) do
    {socket, transport} = state

    with {:ok, request} <- chunk(socket, transport, ""),
         {:ok, response} <- Protohackers.PrimeTime.handle_request(request) do
      :ok = transport.send(socket, response)
      {:noreply, state, {:continue, :loop}}
    else
      {:chunk_error, :closed} ->
        {:stop, :shutdown, state}

      {:chunk_error, reason} ->
        Logger.error("Error chunking: #{inspect(reason)}")
        transport.close(socket)
        {:stop, :shutdown, state}

      {:error, response} ->
        :ok = transport.send(socket, response)
        transport.close(socket)
        {:stop, :shutdown, state}
    end
  end

  defp chunk(socket, transport, request) do
    case transport.recv(socket, 1, :infinity) do
      {:ok, "\n"} -> {:ok, request}
      {:ok, data} -> chunk(socket, transport, request <> data)
      {:error, reason} -> {:chunk_error, reason}
    end
  end

  @impl GenServer
  def handle_info({:tcp_closed, _port}, {socket, transport} = state) do
    transport.close(socket)
    {:stop, :shutdown, state}
  end
end
