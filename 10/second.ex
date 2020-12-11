adapters = fn file ->
  file
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.to_integer/1)
  |> Enum.sort()
end

# sorted = adapters.("input.sample.txt")
# sorted = adapters.("input.sample2.txt")
sorted = adapters.("input.txt")

sorted
|> Enum.reduce(%{0 => 1}, fn adapter, solution ->
  solution
  |> Map.put_new(adapter, 0)
  |> Map.update!(adapter, fn count -> count + Map.get(solution, adapter - 1, 0) end)
  |> Map.update!(adapter, fn count -> count + Map.get(solution, adapter - 2, 0) end)
  |> Map.update!(adapter, fn count -> count + Map.get(solution, adapter - 3, 0) end)
end)
|> Map.get(List.last(sorted))
|> IO.inspect()
