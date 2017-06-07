defmodule Butler.DateInterpreter do
  use Timex
  alias Butler.{Expiration, DateParser, StringEditor}

  @standard_response_format "{WDfull}, {Mfull} {D}, {YYYY}"
  @hours_response_format "{WDfull}, {Mfull} {D}, {YYYY} at {h12}:{m}{AM}"

  def interpret_expiration(user_expiration, start_date \\ Timex.now)
  def interpret_expiration(user_expiration, start_date) when is_nil(start_date) do
    interpret_expiration(user_expiration, Timex.now)
  end

  # Parse expiration from format "in X weeks" or a specified date
  @spec interpret_expiration(String.t, Datetime.t) :: {:ok, Datetime.t, String.t} | {:error, Datetime.t}
  def interpret_expiration(user_expiration, start_date) do
    case String.split(user_expiration) |> List.first do
      nil ->
        IO.puts "interpret_expiration: empty string passed in!"
      "in" ->
        IO.puts "interpret_expiration: IN Case"
        {:ok, expiration} = user_expiration
        |> Expiration.from_relative_string

        format = response_format_from_expiration(expiration)

        expiration
        |> exact_date_from_expiration_struct(start_date)
        |> alexa_response_from_expiration_date(start_date, format)
      "on" ->
        exact_date_from_expiration_text(user_expiration)
        |> alexa_response_from_expiration_date(start_date, @standard_response_format)
      _ ->
        IO.puts "interpret_expiration: no matching pattern!"
    end
  end

  defp exact_date_from_expiration_text(expiration) do
    expiration
    |> StringEditor.sanitize
    |> DateParser.from_string
  end

  defp exact_date_from_expiration_struct(expiration, start_date) do
    IO.puts "shifting start date with expiration"
    IO.inspect start_date
    IO.inspect expiration
    {:ok, Timex.shift(start_date, seconds: expiration.seconds,
         minutes: expiration.minutes, hours: expiration.hours, days: expiration.days,
         weeks: expiration.weeks, months: expiration.months, years: expiration.years)}
  end

  # TODO: CLEANER ERROR HANDLING
  defp alexa_response_from_expiration_date({:ok, expiration_date}, start_date, response_format) do
    IO.puts "parsing alexa response"
    IO.inspect expiration_date
    IO.inspect start_date
    # Ex. in 20 days, on Monday, January 23, 2017
    case Timex.Format.DateTime.Formatters.Relative.relative_to(expiration_date, start_date, "{relative}") do
      {:error, failed_date} ->
        IO.puts "Failed to use relative format for expiration_date: " <> failed_date
        {:error, failed_date}
      {:ok, relative_component} ->
        # exact_component_format = exact_component_format_from_expiration(expiration)
        case Timex.format(expiration_date, response_format) do
          {:error, failed_date} ->
            IO.puts "Failed to convert to full date format for expiration date: " <> failed_date
            {:error, expiration_date}
          {:ok, exact_component} ->
            expiration_string = Enum.join([relative_component, exact_component], ", on ")
            {:ok, expiration_date, expiration_string}
        end
    end
  end

  defp alexa_response_from_expiration_date({:error, _} = error, _, _) do
    error
  end

  defp response_format_from_expiration(expiration) do
    if Expiration.includes_time_components(expiration) do
      @hours_response_format
    else
      @standard_response_format
    end
  end
end
