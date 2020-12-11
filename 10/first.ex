adapters = fn file ->
  file
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.to_integer/1)
  |> Enum.sort()
end

sorted = adapters.('input.sample.txt')
sorted = adapters.('input.sample2.txt')
sorted = adapters.('input.txt')

sorted
|> Enum.zip(tl(sorted))
|> Enum.reduce(%{}, fn {a, b}, acc ->
  Map.update(acc, b-a, 2, fn count -> count + 1 end)
end)
|> IO.inspect()
|> (fn map -> map[3] * map[1] end).()
|> IO.inspect()
