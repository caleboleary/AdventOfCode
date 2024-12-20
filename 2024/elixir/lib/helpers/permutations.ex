# https://stackoverflow.com/a/33769338
defmodule Helpers.Permutations do
  def shuffle(list), do: shuffle(list, length(list))

  def shuffle([], _), do: [[]]
  def shuffle(_,  0), do: [[]]
  def shuffle(list, i) do
    for x <- list, y <- shuffle(list, i-1), do: [x|y]
  end

  def of([]), do: [[]]
  def of(list) do
    for h <- list,
        t <- of(list -- [h]) do
      [h | t]
    end
  end
end
