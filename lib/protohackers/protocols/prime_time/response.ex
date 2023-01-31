defmodule Protohackers.Protocols.PrimeTime.Response do
  alias Protohackers.Protocols.PrimeTime.Request

  defmodule Correct do
    @derive Jason.Encoder
    defstruct [:method, :prime]
  end

  defmodule Malformed do
    @derive Jason.Encoder
    defstruct []
  end

  def from_request(%Request.Malformed{}) do
    struct!(Malformed, %{})
  end

  def from_request(%Request.Valid{} = request) do
    struct!(Correct, %{method: request.method, prime: is_prime?(request.number)})
  end

  def format(response) do
    Jason.encode!(response) <> "\n"
  end

  defp is_prime?(num) when is_float(num), do: false

  defp is_prime?(num) when num < 2, do: false

  defp is_prime?(num) when num in [2, 3], do: true

  defp is_prime?(num) do
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
