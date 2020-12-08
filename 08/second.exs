Code.eval_file("asm.ex")

program = Asm.parse("input.txt")

0..map_size(program)
|> Stream.map(fn index -> Asm.patch(program, index) end)
|> Stream.map(&Asm.run/1)
|> Enum.find_value(fn
  {:error, _, _, _} -> false
  {:ok, acc} -> acc
end)
|> IO.puts() # 2212
