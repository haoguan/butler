defmodule Butler.DateParserTest do
  use ExUnit.Case

  alias Butler.DateParser

  # Enumerated Year

  test "Date with valid month, single word day, and enumerated year with ascending denomination" do
    assert DateParser.from_string("December first nine thousand four hundred and three") == {:ok, ~D[9403-12-01]}
  end

  test "Date with valid month, single word day, and enumerated year with descending denomination" do
    assert DateParser.from_string("january thirtieth three thousand two hundred and eight") == {:ok, ~D[3208-01-30]}
  end

  test "Date with valid month, single word day, and enumerated year with same denomination" do
    assert DateParser.from_string("March fifth two thousand sixteen") == {:ok, ~D[2016-03-05]}
  end

  test "Date with valid month, multiple words day, and enumerated year" do
    assert DateParser.from_string("september twenty second eight hundred thirty three") == {:ok, ~D[0833-09-22]}
  end

  # Brief Year

  test "Date with valid month, single word day, brief year with ascending denomination" do
    assert DateParser.from_string("December tenth twenty eighteen") == {:ok, ~D[2018-12-10]}
  end

  test "Date with valid month, single word day, brief year with descending denomination" do
    assert DateParser.from_string("January thirtieth thirty sixty") == {:ok, ~D[3060-01-30]}
  end

  test "Date with valid month, single word day, and brief year with same denomination" do
    assert DateParser.from_string("july Sixteenth twenty twenty") == {:ok, ~D[2020-07-16]}
  end

end
