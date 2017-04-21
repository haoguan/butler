defmodule Butler.DateParser do

  # Parses: March twenty sixth two thousand seventeen
  def from_string(date_text) do
    date_text
    |> remove_ands_from_string
  end

  # MARK - Month conversions
  defp from_month("january"), do: 1
  defp from_month("february"), do: 2
  defp from_month("march"), do: 3
  defp from_month("april"), do: 4
  defp from_month("may"), do: 5
  defp from_month("june"), do: 6
  defp from_month("july"), do: 7
  defp from_month("august"), do: 8
  defp from_month("september"), do: 9
  defp from_month("october"), do: 10
  defp from_month("november"), do: 11
  defp from_month("december"), do: 12

  # MARK - Calendar date conversions
  defp from_calendar_date("first"), do: 1
  defp from_calendar_date("second"), do: 2
  defp from_calendar_date("third"), do: 3
  defp from_calendar_date("fourth"), do: 4
  defp from_calendar_date("fifth"), do: 5
  defp from_calendar_date("sixth"), do: 6
  defp from_calendar_date("seventh"), do: 7
  defp from_calendar_date("eighth"), do: 8
  defp from_calendar_date("ninth"), do: 9
  defp from_calendar_date("tenth"), do: 10
  defp from_calendar_date("eleventh"), do: 11
  defp from_calendar_date("twelfth"), do: 12
  defp from_calendar_date("thirteenth"), do: 13
  defp from_calendar_date("fourteenth"), do: 14
  defp from_calendar_date("fifteenth"), do: 15
  defp from_calendar_date("sixteenth"), do: 16
  defp from_calendar_date("seventeenth"), do: 17
  defp from_calendar_date("eighteenth"), do: 18
  defp from_calendar_date("nineteenth"), do: 19
  defp from_calendar_date("twentieth"), do: 20
  defp from_calendar_date("twenty first"), do: 21
  defp from_calendar_date("twenty second"), do: 22
  defp from_calendar_date("twenty third"), do: 23
  defp from_calendar_date("twenty fourth"), do: 24
  defp from_calendar_date("twenty fifth"), do: 25
  defp from_calendar_date("twenty sixth"), do: 26
  defp from_calendar_date("twenty seventh"), do: 27
  defp from_calendar_date("twenty eighth"), do: 28
  defp from_calendar_date("twenty nineth"), do: 29
  defp from_calendar_date("thirtieth"), do: 30
  defp from_calendar_date("thirty first"), do: 31
end
