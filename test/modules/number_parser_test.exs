defmodule Butler.NumberParserTest do
  use ExUnit.Case

  alias Butler.NumberParser

  test "simple digit words to numbers" do
    %{
        zero: 0, one: 1, two: 2, three: 3, four: 4, five: 5, six: 6, seven: 7, eight: 8, nine: 9, ten: 10,
        eleven: 11, twelve: 12, thirteen: 13, fourteen: 14, fifteen: 15, sixteen: 16, seventeen: 17,
        eighteen: 18, nineteen: 19
      }
      |>
      Enum.each(fn {word, num} ->
        assert NumberParser.from_string(to_string(word)) == num
      end)
  end

  test "tens words to numbers" do
    %{
      twenty: 20, thirty: 30, forty: 40, fifty: 50, sixty: 60, seventy: 70,
      eighty: 80, ninety: 90
    }
    |>
    Enum.each(fn {word, num} ->
      assert NumberParser.from_string(to_string(word)) == num
    end)
  end

  test "tens with two components" do
    assert NumberParser.from_string("twenty five") == 25
  end

  test "hundreds with three components" do
    assert NumberParser.from_string("three hundred and sixty eight") == 368
  end

  test "hundreds with a single component" do
    assert NumberParser.from_string("eight hundred") == 800
  end

  test "thousands with four components" do
    assert NumberParser.from_string("eight hundred sixty two thousand four hundred ninety one") == 862_491
  end

  test "millions with five components" do
    assert NumberParser.from_string("twelve million and two thousand and one") == 12_002_001
  end

  test "thousands with a single component" do
    assert NumberParser.from_string("one thousand") == 1000
  end

end
