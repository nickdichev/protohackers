defmodule Protohackers.Protocols.PrimeTime.Request do
  defmodule Valid do
    defstruct [:method, :number]
  end

  defmodule Malformed do
    defstruct []
  end

  def parse_request(maybe_valid_request) do
    maybe_valid_request
    |> Jason.decode(keys: :atoms)
    |> do_parse_request()
  end

  defp do_parse_request({:ok, valid_request = %{method: "isPrime", number: number}})
       when is_float(number) or is_integer(number) do
    {:ok, struct!(Valid, valid_request)}
  end

  defp do_parse_request(_error_tuple_or_malformed_request) do
    {:error, %Malformed{}}
  end
end
