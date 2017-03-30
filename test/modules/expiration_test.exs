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

end
