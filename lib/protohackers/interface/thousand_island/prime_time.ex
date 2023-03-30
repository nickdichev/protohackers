defmodule Protohackers.Interface.ThousandIsland.PrimeTime do
  use ThousandIsland.Handler

  alias Protohackers.Core.PrimeTime.Response
  alias Protohackers.Core.PrimeTime.Request

  require Logger

  @impl ThousandIsland.Handler
  def handle_connection(_socket, _state) do
    {:continue, []}
  end

  @impl ThousandIsland.Handler
  def handle_data(data, socket, state) do
    # Don't love the implementation here compared to the ranch counterpart.
    data
    |> String.split("\n", trim: true)
    |> Enum.reduce_while({:continue, state}, fn raw_req, ret ->
      {_, req} = Request.parse_request(raw_req)
      resp = req |> Response.from_request() |> Response.format()

      if match?(%Request.Valid{}, req) do
        Logger.info("Valid request #{inspect(raw_req)} produced response #{inspect(resp)}")
        :ok = ThousandIsland.Socket.send(socket, resp)
        {:cont, ret}
      else
        Logger.info("Invalid request #{inspect(raw_req)} produced response #{inspect(resp)}")
        :ok = ThousandIsland.Socket.send(socket, resp)
        {:halt, {:close, state}}
      end
    end)
  end
end
