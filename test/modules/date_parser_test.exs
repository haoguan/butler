defmodule Butler.DateParserTest do
  use ExUnit.Case
  use Timex

  alias Butler.DateParser

  test "Date with valid month, valid, and future year" do
    assert DateParser.from_string("December 1st, 9403") == {:ok, Timex.to_datetime({9403, 12, 1})}
  end

  test "Date with valid lowercase month, valid day, and future year" do
    assert DateParser.from_string("january 30th 3208") == {:ok, Timex.to_datetime({3208, 1, 30})}
  end

  test "Date with valid month, valid day, and past year" do
    assert DateParser.from_string("March 5th, 2016") == {:ok, Timex.to_datetime({2016, 3, 5})}
  end

  # ERROR TESTS

  test "Date with invalid month, valid day, and valid year" do
    assert DateParser.from_string("Bogus 19th 1999") == {:error, :invalid_month}
  end

  test "Date with valid month, invalid day, and valid year" do
    assert DateParser.from_string("september 32 3499") == {:error, {:invalid_date, {3499, 9, 32}}}
  end

end
