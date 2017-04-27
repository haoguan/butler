defmodule Butler.Denomination do
  def denomination_for(number) when number == 0, do: -1
  def denomination_for(number) when number < 10, do: 1
  def denomination_for(number) do
    1 + denomination_for(number / 10)
  end
end
