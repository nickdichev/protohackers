defmodule Protohakers.Interface.MeansToEndTest do
  use ExUnit.Case, async: true

  describe "single client" do
    test "returns 0 when querying and there are no prices" do
      # Given
      socket = open_socket()

      # When
      :ok = :gen_tcp.send(socket, query_message(0, 1))
      {:ok, response} = :gen_tcp.recv(socket, 0)

      # Then
      assert <<0::big-signed-32>> == response

      close_socket(socket)
    end

    test "returns 0 when querying with mintime > maxtime" do
      # Given
      socket = open_socket()

      # When
      :ok = :gen_tcp.send(socket, query_message(1, 0))
      {:ok, response} = :gen_tcp.recv(socket, 0)

      # Then
      assert <<0::big-signed-32>> == response

      close_socket(socket)
    end

    test "returns 0 when querying and there are no prices in period" do
      # Given
      socket = open_socket()

      # When
      :ok = :gen_tcp.send(socket, insert_message(12345, 100))
      :ok = :gen_tcp.send(socket, insert_message(12346, 102))
      :ok = :gen_tcp.send(socket, insert_message(12347, 101))
      :ok = :gen_tcp.send(socket, query_message(12340, 12344))
      {:ok, response} = :gen_tcp.recv(socket, 0)

      # Then
      assert <<0::big-signed-32>> == response

      close_socket(socket)
    end

    test "returns proper average when query is valid" do
      # Given
      socket = open_socket()

      # When
      :ok = :gen_tcp.send(socket, insert_message(12345, 100))
      :ok = :gen_tcp.send(socket, insert_message(12346, 102))
      :ok = :gen_tcp.send(socket, insert_message(12347, 101))
      :ok = :gen_tcp.send(socket, insert_message(40960, 5))
      :ok = :gen_tcp.send(socket, query_message(12288, 16384))
      {:ok, response} = :gen_tcp.recv(socket, 0)

      # Then
      assert <<101::big-signed-32>> == response

      close_socket(socket)
    end
  end

  # describe "multiple clients" do
  #   test "get responses" do
  #     # |> Task.async_stream(fn number
  #     # end)
  #     # |> Stream.run()
  #   end
  # end

  defp open_socket() do
    opts = [:binary, active: false]
    {:ok, socket} = :gen_tcp.connect({127, 0, 0, 1}, 5557, opts)
    socket
  end

  defp close_socket(socket) do
    :ok = :gen_tcp.close(socket)
  end

  defp insert_message(timestamp, price) do
    <<"I", timestamp::big-signed-integer-32, price::big-signed-integer-32>>
  end

  defp query_message(mintime, maxtime) do
    <<"Q", mintime::big-signed-integer-32, maxtime::big-signed-integer-32>>
  end
end
