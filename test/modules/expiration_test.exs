defmodule Butler.ExpirationTest do
  use Butler.ConnCase
  use ExUnit.Case

  alias Butler.Expiration

  test "simple relative expiration" do
    assert Expiration.from_relative_string("in twenty days") == %Expiration{days: 20}
  end

  test "relative expiration with different components" do
    assert Expiration.from_relative_string("in two weeks five days and six hours") == %Expiration{weeks: 2, days: 5, hours: 6}
  end

  test "relative expiration with component that isn't plural" do
    assert Expiration.from_relative_string("in three months one week") == %Expiration{months: 3, weeks: 1}
  end

  test "relative expiration with component that has multiple number parts" do
    assert Expiration.from_relative_string("in three hundred eighty seven days") == %Expiration{days: 387}
  end

  test "relative expiration with multiple components that has multiple number parts" do
    assert Expiration.from_relative_string("in thirty nine years seventy one days") == %Expiration{years: 39, days: 71}
  end

end
