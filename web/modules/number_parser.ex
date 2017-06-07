alias Butler.Denomination

# TODO: ERROR HANDLING FOR NON-NUMBER VALUES
defmodule Butler.NumberParser do
  def from_string("zero"), do: 0
  def from_string("one"), do: 1
  def from_string("first"), do: 1
  def from_string("two"), do: 2
  def from_string("second"), do: 2
  def from_string("three"), do: 3
  def from_string("third"), do: 3
  def from_string("four"), do: 4
  def from_string("fourth"), do: 4
  def from_string("five"), do: 5
  def from_string("fifth"), do: 5
  def from_string("six"), do: 6
  def from_string("sixth"), do: 6
  def from_string("seven"), do: 7
  def from_string("seventh"), do: 7
  def from_string("eight"), do: 8
  def from_string("eighth"), do: 8
  def from_string("nine"), do: 9
  def from_string("ninth"), do: 9
  def from_string("ten"), do: 10
  def from_string("tenth"), do: 10

  def from_string("eleven"), do: 11
  def from_string("eleventh"), do: 11
  def from_string("twelve"), do: 12
  def from_string("twelfth"), do: 12
  def from_string("thirteen"), do: 13
  def from_string("thirteenth"), do: 13
  def from_string("fourteen"), do: 14
  def from_string("fourteenth"), do: 14
  def from_string("fifteen"), do: 15
  def from_string("fifteenth"), do: 15
  def from_string("sixteen"), do: 16
  def from_string("sixteenth"), do: 16
  def from_string("seventeen"), do: 17
  def from_string("seventeenth"), do: 17
  def from_string("eighteen"), do: 18
  def from_string("eighteenth"), do: 18
  def from_string("nineteen"), do: 19
  def from_string("nineteenth"), do: 19
  def from_string("twenty"), do: 20
  def from_string("twentieth"), do: 20

  def from_string("thirty"), do: 30
  def from_string("thirtieth"), do: 30
  def from_string("forty"), do: 40
  def from_string("fifty"), do: 50
  def from_string("sixty"), do: 60
  def from_string("seventy"), do: 70
  def from_string("eighty"), do: 80
  def from_string("ninety"), do: 90

  def from_string("hundred"), do: 100
  def from_string("thousand"), do: 1_000
  def from_string("million"), do: 1_000_000
  def from_string("billion"), do: 1_000_000_000

  @large_number_units ["thousand", "million", "billion"]

  # General parser from a number text
  def from_string(number) do
    case Integer.parse(number) do
      {number, _} ->
        number
      :error ->
        partitions =
          number
          |> remove_ands_from_string
          |> add_split_characters(@large_number_units, "|")
          |> String.split("|")
        Enum.reduce(partitions, 0, fn(partition, acc) ->
          acc + calculate_number_partition(partition)
        end)
    end
  end

  # Add split component to number string for partitioning, keeps all units intact.
  defp add_split_characters(number_string, patterns, split_character) do
    Enum.reduce(patterns, number_string, fn(pattern, working_string) ->
      String.replace(working_string, pattern, pattern <> split_character)
    end)
  end

  # For each number in partition, we add or multiply depending on unit
  defp calculate_number_partition(partition) do
    components = partition |> String.trim |> String.split
    Enum.reduce(components, 0, fn(component, acc) ->
      number = from_string(component)
      acc_denom = Denomination.calculate(acc)
      number_denom = Denomination.calculate(number)
      cond do
        # EDGE CASE FOR 0 (beginning state) to ensure we start off adding
        acc_denom < 0 ->
          acc + number
        number_denom > acc_denom ->
          acc * number
        number_denom < acc_denom ->
          acc + number
        number_denom == acc_denom ->
          # NOTE: parse returns {34, <remainder>}
          elem(Integer.parse(Integer.to_string(acc) <> Integer.to_string(number)), 0)
      end
    end)
  end

  defp remove_ands_from_string(text) do
    String.replace(text, " and ", " ")
  end
end
