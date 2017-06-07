defprotocol Butler.Searchable do
  @doc "Asks if the passed in item is contained within data structure"
  def contains(collection, item)
end

defimpl Butler.Searchable, for: List do
  def contains([head | tail], item) do
    if head == item do
      true
    else
      contains(tail, item)
    end
  end

  def contains([], _item) do
    false
  end
end
