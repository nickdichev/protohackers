defmodule Protohackers.PrimeTime do
  require Logger

  def handle_request(maybe_valid_request) do
    Logger.info(maybe_valid_request)
    request = parse_request(maybe_valid_request)

    case request do
      {:ok, request} ->
        is_prime = is_prime?(request.number)
        {:ok, response(is_prime)}

      {:error, :malformed_request} ->
        {:error, malformed_response()}
    end
  end

  def parse_request(maybe_valid_request) do
    maybe_valid_request
    |> Jason.decode(keys: :atoms)
    |> do_parse_request()
  end

  defp do_parse_request({:ok, valid_request = %{method: "isPrime", number: number}})
       when is_float(number) or is_integer(number) do
    {:ok, valid_request}
  end

  defp do_parse_request(_error_tuple_or_malformed_request) do
    {:error, :malformed_request}
  end

  def response(is_prime) do
    response = %{method: "isPrime", prime: is_prime} |> Jason.encode!()
    response <> "\n"
  end

  def malformed_response do
    Jason.encode!(%{}) <> "\n"
  end

  def is_prime?(num) when is_float(num), do: false

  def is_prime?(num) when num < 2, do: false

  def is_prime?(num) when num in [2, 3], do: true

  def is_prime?(num) do
    last =
      num
      |> :math.sqrt()
      |> Float.ceil()
      |> trunc

    notprime =
      2..last
      |> Enum.any?(fn a -> rem(num, a) == 0 end)

    !notprime
  end
end
