defmodule Protohackers.Core.PrimeTime.ResponseTest do
  use ExUnit.Case, async: true

  alias Protohackers.Core.PrimeTime.Response
  alias Protohackers.Core.PrimeTime.Request

  describe "from_request/1" do
    test "handles a valid request" do
      request = %Request.Valid{method: "isPrime", number: 42}
      assert %Response.Correct{method: "isPrime", prime: false} == Response.from_request(request)
    end

    test "handles a malformed request" do
      request = %Request.Malformed{}
      assert %Response.Malformed{} == Response.from_request(request)
    end
  end

  describe "format/1" do
    test "properly formats a correct response" do
      response = %Response.Correct{method: "isPrime", prime: true}

      assert %{"method" => "isPrime", "prime" => true} =
               Response.format(response) |> Jason.decode!()
    end

    test "properly formats a malformed response" do
      assert %{} == Response.format(%Response.Malformed{}) |> Jason.decode!()
    end
  end
end
