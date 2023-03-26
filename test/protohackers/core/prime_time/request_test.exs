defmodule Protohackers.Core.PrimeTime.RequestTest do
  use ExUnit.Case, async: true

  alias Protohackers.Core.PrimeTime.Request

  describe "parse_request/1" do
    test "parses a valid request" do
      request = %{method: "isPrime", number: 100} |> Jason.encode!()

      assert {:ok, %Request.Valid{method: "isPrime", number: 100}} ==
               Request.parse_request(request)
    end

    test "parsed a valid request with extra keys" do
      request = %{method: "isPrime", number: 100, bogus: :key} |> Jason.encode!()

      assert {:ok, %Request.Valid{method: "isPrime", number: 100}} ==
               Request.parse_request(request)
    end

    test "parses an invalid request (missing method)" do
      request = %{number: 100} |> Jason.encode!()
      assert {:error, %Request.Malformed{}} == Request.parse_request(request)
    end

    test "parses an invalid request (invalid method)" do
      request = %{method: "isCapybara", number: 100} |> Jason.encode!()
      assert {:error, %Request.Malformed{}} == Request.parse_request(request)
    end

    test "parses an invalid request (number is not a number)" do
      request = %{method: "isPrime", number: "boom"} |> Jason.encode!()
      assert {:error, %Request.Malformed{}} == Request.parse_request(request)
    end
  end
end
