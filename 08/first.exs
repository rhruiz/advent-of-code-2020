Code.eval_file("asm.ex")

"input.txt"
|> Asm.parse()
|> Asm.run()
|> (fn {:error, :loop, _index, acc} -> acc end).()
|> IO.puts # 1939
