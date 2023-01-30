defmodule Protohackers.Protocols.MeansToEnd.Request do
  def parse_request(<<"I", timestamp::size(32), price::size(32)>> = _request) do
    {:insert, %{timestamp: timestamp, price: price}}
  end

  def parse_request(<<"Q", min_time::size(32), max_time::size(32)>> = _request) do
    {:query, %{min_time: min_time, max_time: max_time}}
  end
end
