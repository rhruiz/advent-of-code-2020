defmodule XMAS do
  def parse(file) do
    file
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
  end

  def combinations(list, num)
  def combinations(_list, 0), do: [[]]
  def combinations(list = [], _num), do: list

  def combinations([head | tail], num) do
    Enum.map(combinations(tail, num - 1), &[head | &1]) ++
      combinations(tail, num)
  end

  def find_broken(numbers, range) do
    preamble = numbers |> Stream.take(range) |> Enum.into([]) |> :queue.from_list()

    numbers |> Stream.drop(range) |> Enum.reduce_while(preamble, fn target, preamble ->
      preamble
      |> :queue.to_list()
      |> combinations(2)
      |> Enum.find(:broken, fn [n, m] -> n != m && n + m == target end)
      |> (fn
        :broken ->
          {:halt, target}
        _other ->
          {{:value, _}, preamble} = :queue.out(preamble)
          preamble = :queue.in(target, preamble)

          {:cont, preamble}
      end).()
    end)
  end

  def find_sum_of(numbers, target) do
    find_sum_of(target, 0, :queue.new(), Enum.into(numbers, []))
  end

  def find_sum_of(target, sum, sumees, _) when target == sum do
    :queue.to_list(sumees)
  end

  def find_sum_of(target, sum, sumees, [candidate | queue]) when sum < target do
    sumees = :queue.in(candidate, sumees)

    find_sum_of(target, sum + candidate, sumees, queue)
  end

  def find_sum_of(target, sum, sumees, queue) when sum > target do
    {{:value, first}, sumees} = :queue.out(sumees)
    find_sum_of(target, sum - first, sumees, queue)
  end
end

numbers = XMAS.parse('input.sample.txt')
range = 5

target = XMAS.find_broken(numbers, range)
IO.puts target

numbers = XMAS.parse('input.txt')
range = 25

target = XMAS.find_broken(numbers, range)
IO.inspect(target, label: "Number that breaks XMAS")

the_sum = XMAS.find_sum_of(numbers, target)
IO.inspect(the_sum, label: "sum factors")

Enum.min_max(the_sum) |> Tuple.to_list() |> Enum.reduce(&Kernel.+/2) |> IO.puts()
