defmodule Butler.StringEditor do
  # Add split component to number string for partitioning, keeps all units intact.
  def add_split_characters(number_string, patterns, split_character) do
    Enum.reduce(patterns, number_string, fn(pattern, working_string) ->
      String.replace(working_string, pattern, pattern <> split_character)
    end)
  end

  def sanitize(string) do
    string
      |> String.downcase
      |> remove_conjunctions_from_string
      |> remove_punctuation_from_string
  end

  defp remove_conjunctions_from_string(text) do
    text
      |> String.replace(" and ", " ")
      |> String.replace("on ", " ")
      |> String.replace("in ", " ")
      |> String.trim
  end

  defp remove_punctuation_from_string(text) do
    text
      |> String.replace(", ", " ")
      |> String.trim
  end
end
