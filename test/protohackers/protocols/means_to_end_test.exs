defmodule Protohakers.Protocols.MeansToEndTest do
  use ExUnit.Case, async: true

  describe "single client" do
    test "gets response" do
      # Given
      socket = open_socket()

      # When
      :ok = :gen_tcp.send(socket, insert_message())
      :ok = :gen_tcp.send(socket, insert_message())
      :ok = :gen_tcp.send(socket, insert_message())
      :ok = :gen_tcp.send(socket, query_message())
      {:ok, response} = :gen_tcp.recv(socket, 0)
      :ok = :gen_tcp.close(socket)

      # Then
      assert "boo" == response

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
    opts = [:binary, active: false, packet: :line]
    {:ok, socket} = :gen_tcp.connect({127, 0, 0, 1}, 5557, opts)
    socket
  end

  defp close_socket(socket) do
    :ok = :gen_tcp.close(socket)
  end

  defp insert_message() do
    <<"I", 12345::big-signed-integer-32, 101::big-signed-integer-32>>
  end

  defp query_message() do
    <<"Q", 12345::big-signed-integer-32, 101::big-signed-integer-32>>
  end
end
