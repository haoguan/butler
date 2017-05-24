alias Butler.{NumberParser, StringEditor}
use Timex

defmodule Butler.DateParser do

  @month_days [
    "1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th", "9th", "10th",
    "11th", "12th", "13th", "14th", "15th", "16th", "17th", "18th", "19th", "20th",
    "21th", "22nd", "23rd", "24th", "25th", "26th", "27th", "28th", "29th", "30th",
    "31st"
  ]

  # Parses: Alexa gives us format March 26th, 2017
  def from_string(date_text) do
    parsed_month = parse_month(date_text)
    case parsed_month do
      {:ok, month, remaining_text} ->
        {:ok, day, year} = parse_day_and_year(remaining_text)
        to_timex_datetime(year, month, day)
      {:error, error} ->
        {:error, error}
    end
  end

  defp to_timex_datetime(year, month, day) do
    try do
      case Timex.to_datetime({year, month, day}) do
        {:error, _} ->
          {:error, {:invalid_date, {year, month, day}}}
        datetime ->
          {:ok, datetime}
      end
    rescue
      _ ->
        {:error, {:invalid_date, {year, month, day}}}
    end
  end

  defp parse_month(date_text) do
    {month_text, remaining} =
      date_text
      |> StringEditor.sanitize
      |> String.split
      |> List.pop_at(0)

    case from_month(month_text) do
      {:ok, month} ->
        {:ok, month}
        |> Tuple.append(Enum.join(remaining, " "))
      {:error, error} ->
        {:error, error}
    end
  end

  defp parse_day_and_year(date_text) do
    date_components =
      date_text
      |> StringEditor.sanitize
      |> String.split
    # IO.inspect date_components
    cond do
      list_size(date_components) != 2 ->
        {:error, :invalid_date_components}
      true ->
        day =
          date_components
          |> List.first
          |> StringEditor.sanitize
          |> NumberParser.from_string
        year =
          date_components
          |> List.last
          |> StringEditor.sanitize
          |> NumberParser.from_string
        {:ok, day, year}
    end
  end

  defp list_size(list) do
    Enum.reduce(list, 0, fn _, acc ->
      acc + 1
    end)
  end

  # MARK - Month conversions
  defp from_month("january"), do: {:ok, 1}
  defp from_month("february"), do: {:ok, 2}
  defp from_month("march"), do: {:ok, 3}
  defp from_month("april"), do: {:ok, 4}
  defp from_month("may"), do: {:ok, 5}
  defp from_month("june"), do: {:ok, 6}
  defp from_month("july"), do: {:ok, 7}
  defp from_month("august"), do: {:ok, 8}
  defp from_month("september"), do: {:ok, 9}
  defp from_month("october"), do: {:ok, 10}
  defp from_month("november"), do: {:ok, 11}
  defp from_month("december"), do: {:ok, 12}
  defp from_month(_), do: {:error, :invalid_month}
end
