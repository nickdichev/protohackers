defmodule Protohakers.Protocols.PrimeTimeTest do
  use ExUnit.Case, async: true

  describe "single client" do
    test "gets response" do
      socket = open_socket()

      assert %{method: "isPrime", prime: true} ==
               request(socket, %{method: "isPrime", number: 13})

      close_socket(socket)
    end
  end

  describe "multiple clients" do
    test "get responses" do
      [1, 8, 13, 42, 100, -1, 12.5]
      |> Task.async_stream(fn number ->
        socket = open_socket()

        assert %{method: "isPrime", prime: prime} =
                 request(socket, %{method: "isPrime", number: number})

        assert is_boolean(prime)

        close_socket(socket)
      end)
      |> Stream.run()
    end
  end

  defp open_socket() do
    opts = [:binary, active: false, packet: :line]
    {:ok, socket} = :gen_tcp.connect({127, 0, 0, 1}, 5556, opts)
    socket
  end

  defp close_socket(socket) do
    :ok = :gen_tcp.close(socket)
  end

  defp request(socket, request) do
    request = Jason.encode!(request) <> "\n"
    :ok = :gen_tcp.send(socket, request)

    {:ok, response} = :gen_tcp.recv(socket, 0)
    Jason.decode!(response, keys: :atoms)
  end
end
