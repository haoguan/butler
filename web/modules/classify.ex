defmodule Expiration do
  defstruct seconds: 0, minutes: 0, hours: 0, days: 0,
    weeks: 0, months: 0, years: 0
end

defmodule Butler.Classify do
  use Timex

  expirationTiers = %{
    :WEEK_1 => %Expiration{weeks: 1},
    :WEEK_2 => %Expiration{weeks: 2},
    :WEEK_3 => %Expiration{weeks: 3},
    :MONTH_1 => %Expiration{months: 1},
    :MONTH_2 => %Expiration{months: 2},
    :MONTH_6 => %Expiration{months: 6},
    :YEAR_1 => %Expiration{years: 1}
  }

  # Module constant, can be used in funcs
  # TODO: Add support for multi sized item keys!
  @itemExpirations %{
    ##############
    ## CLEANING ##
    ##############

    # Tier 1
    :bedsheets => expirationTiers[:MONTH_1],
    :blankets => expirationTiers[:MONTH_1],
    :sheets => expirationTiers[:MONTH_1],
    :towels => expirationTiers[:MONTH_1],

    # Tier 2
    :blinds => expirationTiers[:MONTH_2],
    :desk => expirationTiers[:MONTH_2],
    :fridge => expirationTiers[:MONTH_2],
    :table => expirationTiers[:MONTH_2],

    ################
    ## PERISHABLE ##
    ################

    # Tier 1
    :leftovers => expirationTiers[:WEEK_1],

    # Tier 2
    :milk => expirationTiers[:WEEK_2],
    # :"pasta sauce" => expirationTiers[:WEEK_2],

    # Tier 3
    :butter => expirationTiers[:WEEK_3],
    :cheese => expirationTiers[:WEEK_3],

    # Tier 4
    :ketchup => expirationTiers[:MONTH_1],
    :mustard => expirationTiers[:MONTH_1],
    # :"hoisin sauce" => expirationTiers[:MONTH_1],
    :siracha => expirationTiers[:MONTH_1],

    #################
    ## REPLACEABLE ##
    #################

    # Tier 1
    :loofah => expirationTiers[:MONTH_2],
    :sponge => expirationTiers[:MONTH_2],

    # Tier 2
    :toothbrush => expirationTiers[:MONTH_3],
    # :"toothbrush head" => expirationTiers[:MONTH_3],
    :clarisonic => expirationTiers[:MONTH_3],
    # :"clarisonic head" => expirationTiers[:MONTH_3],
    # :"contact case" => expirationTiers[:MONTH_3]
  }

  # @spec expirationDateForItem(String.t, DateTime.t) :: DateTime.t | {:error, String.t}
  def expirationDateForItem(item, start_date \\ Timex.now()) do
    item_atom = String.to_atom(item)
    # Using subscript notation will return nil for non-existing key
    # Using dot notation will throw KeyError instead
    case @itemExpirations[item_atom] do
      nil ->
        IO.puts item <> " could not be found in list"
        {:error, item}
      expiration ->
        Timex.shift(start_date, seconds: expiration.seconds,
          minutes: expiration.minutes, hours: expiration.hours, days: expiration.days,
          months: expiration.months, years: expiration.years)
    end
  end

  def interpret_term(raw_term) do
    # Find index of the type in words list
    words = raw_term |> String.split(" ", trim: true)
    type_index = words |> Enum.find_index(fn word ->
      Map.has_key?(@itemExpirations, String.to_atom(word))
    end)

    # Skip error check because index already verified
    {:ok, type} = words |> Enum.fetch(type_index)

    # TODO: Handle complex expressions like "Angelina's bedsheets in the room"
    # Ignore words after the type has been identified
    modifier = words |> Enum.take(type_index) |> Enum.join(" ")
    %{:type => type, :modifier => modifier}
  end
end
