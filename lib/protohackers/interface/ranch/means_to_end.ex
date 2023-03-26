defmodule Protohackers.Interface.Ranch.MeansToEnd do
  use GenServer

  alias Protohackers.Core.MeansToEnd.Request

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

    state = %{socket: socket, transport: transport, prices: []}

    {:noreply, state, {:continue, :loop}}
  end

  @impl GenServer
  def handle_continue(:loop, state) do
    %{socket: socket, transport: transport} = state

    case transport.recv(socket, 9, @timeout) do
      {:ok, request} ->
        parsed_request = Request.parse_request(request)
        process_request(parsed_request, state)

      {:error, :closed} ->
        transport.close(socket)
        {:stop, :shutdown, state}
    end
  end

  defp process_request({:insert, insert_data}, state) do
    %{timestamp: timestamp, price: price} = insert_data

    state = %{state | prices: [{timestamp, price} | state.prices]}
    {:noreply, state, {:continue, :loop}}
  end

  defp process_request({:query, %{min_time: min_time, max_time: max_time}}, state)
       when min_time > max_time do
    %{socket: socket, transport: transport} = state

    :ok = transport.send(socket, <<0::big-signed-32>>)
    {:noreply, state, {:continue, :loop}}
  end

  defp process_request({:query, _query}, %{prices: []} = state) do
    %{socket: socket, transport: transport} = state

    :ok = transport.send(socket, <<0::big-signed-32>>)
    {:noreply, state, {:continue, :loop}}
  end

  defp process_request({:query, query}, state) do
    %{socket: socket, transport: transport, prices: prices} = state
    %{min_time: min_time, max_time: max_time} = query

    prices_in_range =
      prices
      |> Enum.filter(fn {timestamp, _price} ->
        timestamp >= min_time and timestamp <= max_time
      end)
      |> Enum.map(fn {_timestamp, price} -> price end)

    sum = Enum.sum(prices_in_range)
    count = Enum.count(prices_in_range)

    average =
      if count > 0 do
        (sum / count) |> floor()
      else
        0
      end

    :ok = transport.send(socket, <<average::big-signed-32>>)
    {:noreply, state, {:continue, :loop}}
  end

  @impl GenServer
  def handle_info({:tcp_closed, _port}, {socket, transport} = state) do
    transport.close(socket)
    {:stop, :shutdown, state}
  end
end
