defmodule Butler.DateInterpreterTest do
  use Butler.ConnCase
  use ExUnit.Case

  alias Butler.DateInterpreter

  # RELATIVE EXPIRATION

  test "future relative expiration date using days" do
    test_start_date = Timex.to_datetime({2017, 4, 4})
    {:ok, _, relative_expiration} = DateInterpreter.interpret_expiration("in twenty days", test_start_date)
    assert relative_expiration == "in 20 days, on Monday, April 24, 2017"
  end

  test "future relative expiration using months and days" do
    test_start_date = Timex.to_datetime({2017, 4, 4})
    {:ok, _, relative_expiration} = DateInterpreter.interpret_expiration("in three months and twelve days", test_start_date)
    # NOTE: Relative component will only specify the largest unit
    assert relative_expiration == "in 3 months, on Sunday, July 16, 2017"
  end

  test "future relative expiration using irregular months and days" do
    test_start_date = Timex.to_datetime({2017, 4, 4})
    {:ok, _, relative_expiration} = DateInterpreter.interpret_expiration("in three months and zero days", test_start_date)
    assert relative_expiration == "in 3 months, on Tuesday, July 4, 2017"
  end

  test "future relative expiration shifted by hours" do
    test_start_date = Timex.to_datetime({{2017, 4, 4}, {10, 25, 0}})
    {:ok, _, relative_expiration} = DateInterpreter.interpret_expiration("in eight hours", test_start_date)
    # TODO: Add quality of life change to exchange full date with "today" if makes sense.
    assert relative_expiration == "in 8 hours, on Tuesday, April 4, 2017 at 6:25PM"
  end

  test "future relative expiration shifted by hours that spills into the next day" do
    test_start_date = Timex.to_datetime({{2017, 4, 4}, {10, 25, 0}})
    {:ok, _, relative_expiration} = DateInterpreter.interpret_expiration("in fifteen hours", test_start_date)
    assert relative_expiration == "in 15 hours, on Wednesday, April 5, 2017 at 1:25AM"
  end

  test "future relative expiration shifted by hours and minutes that spills into the next day" do
    test_start_date = Timex.to_datetime({{2017, 4, 4}, {10, 25, 0}})
    {:ok, _, relative_expiration} = DateInterpreter.interpret_expiration("in fifteen hours and thirty six minutes", test_start_date)
    assert relative_expiration == "in 15 hours, on Wednesday, April 5, 2017 at 2:01AM"
  end

  # TODO: Test expirations that have already expired, or on the same day!

  # EXACT EXPIRATION

  test "future exact expiration date in one day" do
    test_start_date = Timex.to_datetime({2017, 4, 4})
    {:ok, _, exact_expiration} = DateInterpreter.interpret_expiration("on April fifth twenty seventeen", test_start_date)
    assert exact_expiration == "in 1 day, on Wednesday, April 5, 2017"
  end

  test "future exact expiration date within a few days" do
    test_start_date = Timex.to_datetime({2017, 4, 4})
    {:ok, _, exact_expiration} = DateInterpreter.interpret_expiration("on april Eighth two thousand seventeen", test_start_date)
    assert exact_expiration == "in 4 days, on Saturday, April 8, 2017"
  end

  test "future exact expiration date within weeks" do
    test_start_date = Timex.to_datetime({2017, 4, 4})
    {:ok, _, exact_expiration} = DateInterpreter.interpret_expiration("on April twenty third twenty seventeen", test_start_date)
    assert exact_expiration == "in 19 days, on Sunday, April 23, 2017"
  end

  test "future exact expiration date within a month" do
    test_start_date = Timex.to_datetime({2017, 4, 4})
    {:ok, _, exact_expiration} = DateInterpreter.interpret_expiration("on May second two thousand and seventeen", test_start_date)
    assert exact_expiration == "in 28 days, on Tuesday, May 2, 2017"
  end

end
