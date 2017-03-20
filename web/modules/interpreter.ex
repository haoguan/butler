defmodule Butler.Interpreter do
  use Timex

  # Parse expiration from format "in X weeks" or a specified date
  @spec interpret_expiration(String.t) :: {:ok, Datetime.t, String.t} | {:error, String.t}
  def interpret_expiration(user_expiration) do
    case String.split(user_expiration).first do
      nil ->
        IO.puts "interpret_expiration: empty string passed in!"
      "in" ->
        interpret_relative_expiration(user_expiration)
      "on" ->
        interpret_exact_expiration(user_expiration)
      _ ->
        IO.puts "interpret_expiration: no matching pattern!"
    end
  end

  defp interpret_relative_expiration(user_expiration) do
    # Pop first word, which should be "in"
    relative_expiration = String.split(user_expiration) |> List.delete_at(0) |> List.to_string
    # TODO: Need to parse number strings to integers!
  end

  defp interpret_exact_expiration(user_expiration) do

  end
end
