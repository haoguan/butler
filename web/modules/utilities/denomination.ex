defmodule Butler.Denomination do
  def calculate(number) when number == 0, do: -1
  def calculate(number) when number < 10, do: 1
  def calculate(number) do
    1 + calculate(number / 10)
  end
end
