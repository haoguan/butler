alias Butler.NumberParser
alias Butler.StringEditor

defmodule Butler.Expiration do
  defstruct seconds: 0, minutes: 0, hours: 0, days: 0,
    weeks: 0, months: 0, years: 0

  @time_units %{
    "second" => :seconds,
    "minute" => :minutes,
    "hour" => :hours,
    "day" => :days,
    "week" => :weeks,
    "month" => :months,
    "year" => :years
  }

  def from_relative_string(expiration) do
    time_components =
      expiration
      |> StringEditor.sanitize
      # TODO: More robust using regular expressions!
      |> StringEditor.add_split_characters(Map.keys(@time_units), "|")
      |> String.split(["|", "|s"], trim: true)
      |> Enum.filter(fn element ->
        element != "s" || String.length(element) > 1
      end)

    # TODO: Error handling for when time unit isn't found in the map
    params = Enum.reduce(time_components, %{}, fn(time_component, working_expiration) ->
      time_component_parts = time_component |> String.trim |> String.split
      time_unit = time_component_parts |> List.last
      time_component_without_unit =
        time_component_parts
        |> List.delete_at(-1)
        |> Enum.join(" ")
      computed_time = time_component_without_unit |> NumberParser.from_string
      Map.put(working_expiration, @time_units[time_unit], computed_time)
    end)
    struct(Butler.Expiration, params)
  end

  def includes_time_components(expiration) do
    expiration.hours != 0 || expiration.minutes != 0 || expiration.seconds != 0
  end
end
