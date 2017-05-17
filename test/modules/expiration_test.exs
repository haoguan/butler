defmodule Butler.ExpirationTest do
  use Butler.ConnCase
  use ExUnit.Case

  alias Butler.Expiration

  # String number tests

  test "simple relative expiration" do
    assert Expiration.from_relative_string("in twenty days") == {:ok, %Expiration{days: 20}}
  end

  test "relative expiration with different components" do
    assert Expiration.from_relative_string("in two weeks five days and six hours") == {:ok, %Expiration{weeks: 2, days: 5, hours: 6}}
  end

  test "relative expiration with component that isn't plural" do
    assert Expiration.from_relative_string("in three months one week") == {:ok, %Expiration{months: 3, weeks: 1}}
  end

  test "relative expiration with component that has multiple number parts" do
    assert Expiration.from_relative_string("in three hundred eighty seven days") == {:ok, %Expiration{days: 387}}
  end

  test "relative expiration with multiple components that has multiple number parts" do
    assert Expiration.from_relative_string("in thirty nine years seventy one days") == {:ok, %Expiration{years: 39, days: 71}}
  end

  # Number tests

  test "simple relative number expiration" do
    assert Expiration.from_relative_string("in 20 days") == {:ok, %Expiration{days: 20}}
  end

  test "relative expiration with different number components" do
    assert Expiration.from_relative_string("in 2 weeks 5 days and 6 hours") == {:ok, %Expiration{weeks: 2, days: 5, hours: 6}}
  end

end
