defmodule Butler.DateInterpreter do
  use Timex
  alias Butler.Expiration

  # Parse expiration from format "in X weeks" or a specified date
  @spec interpret_expiration(String.t, Datetime.t) :: {:ok, Datetime.t, String.t} | {:error, Datetime.t}
  def interpret_expiration(user_expiration, start_date \\ Timex.now) do
    case String.split(user_expiration) |> List.first do
      nil ->
        IO.puts "interpret_expiration: empty string passed in!"
      "in" ->
        expiration = Expiration.from_relative_string(user_expiration)
        relative_response_from_expiration(expiration, start_date)
      "on" ->
        Expiration.from_exact_string(user_expiration)
      _ ->
        IO.puts "interpret_expiration: no matching pattern!"
    end
  end

  defp relative_response_from_expiration(expiration, start_date) do
    expiration_date = Timex.shift(start_date, seconds: expiration.seconds,
         minutes: expiration.minutes, hours: expiration.hours, days: expiration.days,
         months: expiration.months, years: expiration.years)
    # Ex. in 20 days, on Monday, January 23, 2017
    case Timex.Format.DateTime.Formatters.Relative.relative_to(expiration_date, start_date, "{relative}") do
      {:error, failed_date} ->
        IO.puts "Failed to use relative format for expiration_date: " <> failed_date
        {:error, failed_date}
      {:ok, relative_component} ->
        exact_component_format = exact_component_format_from_expiration(expiration)
        case Timex.format(expiration_date, exact_component_format) do
          {:error, failed_date} ->
            IO.puts "Failed to convert to full date format for expiration date: " <> failed_date
            {:error, expiration_date}
          {:ok, exact_component} ->
            expiration_string = Enum.join([relative_component, exact_component], ", on ")
            {:ok, expiration_date, expiration_string}
        end
    end
  end

  defp exact_component_format_from_expiration(expiration) do
    if Expiration.includes_time_components(expiration) do
      "{WDfull}, {Mfull} {D}, {YYYY} at {h12}:{m}{AM}"
    else
      "{WDfull}, {Mfull} {D}, {YYYY}"
    end
  end
end
