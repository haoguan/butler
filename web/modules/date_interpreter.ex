defmodule Butler.DateInterpreter do
  use Timex
  alias Butler.Expiration

  # Parse expiration from format "in X weeks" or a specified date
  @spec interpret_expiration(String.t, Datetime.t) :: {:ok, Datetime.t, String.t} | {:error, String.t}
  def interpret_expiration(user_expiration, start_date \\ Timex.now) do
    case String.split(user_expiration).first do
      nil ->
        IO.puts "interpret_expiration: empty string passed in!"
      "in" ->
        expiration = Expiration.from_relative_string(user_expiration)
        expiration_date = Timex.shift(start_date, seconds: expiration.seconds,
             minutes: expiration.minutes, hours: expiration.hours, days: expiration.days,
             months: expiration.months, years: expiration.years)

        # Ex. 20 days from now, on Monday, January 23, 2017
        case Timex.format(expiration_date, "{relative}", Timex.Format.DateTime.Formatters.Relative) do
          {:error, term} ->
            IO.puts item <> " RELATIVE could not be found in list"
            {:error, item}
          {:ok, relative_component} ->
            case Timex.format(expiration_date, "{WDfull}, {Mfull} {D}, {YYYY}") do
              {:error, term} ->
                IO.puts item <> " could not be found in list"
                {:error, item}
              {:ok, full_component} ->
                expiration_string = Enum.join([relative_component, full_component], ", on ")
                {:ok, expiration_date, expiration_string}
            end
        end
      "on" ->
        Expiration.from_exact_string(user_expiration)
      _ ->
        IO.puts "interpret_expiration: no matching pattern!"
    end
  end
end
