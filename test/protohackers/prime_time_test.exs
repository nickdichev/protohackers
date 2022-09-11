defmodule Protohackers.PrimeTimeTest do
  use ExUnit.Case

  alias Protohackers.PrimeTime

  describe "parse_request/1" do
    test "parses a valid request" do
      request = %{method: "isPrime", number: 100} |> Jason.encode!()
      assert {:ok, %{method: "isPrime", number: 100}} == PrimeTime.parse_request(request)
    end

    test "parses an invalid request (missing method)" do
      request = %{number: 100} |> Jason.encode!()
      assert {:error, :malformed_request} == PrimeTime.parse_request(request)
    end

    test "parses an invalid request (invalid method)" do
      request = %{method: "isCapybara", number: 100} |> Jason.encode!()
      assert {:error, :malformed_request} == PrimeTime.parse_request(request)
    end

    test "parses an invalid request (number is not a number)" do
      request = %{method: "isPrime", number: "boom"} |> Jason.encode!()
      assert {:error, :malformed_request} == PrimeTime.parse_request(request)
    end
  end

  describe "response/1" do
    test "returns a valid response" do
      assert %{"method" => "isPrime", "prime" => true} ==
               PrimeTime.response(true) |> Jason.decode!()
    end
  end

  describe "malformed_response/0" do
    test "returns an empty JSON object" do
      assert %{} == PrimeTime.malformed_response() |> Jason.decode!()
    end
  end
end
