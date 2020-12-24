defmodule Hex do
  def parse(file) do
    file
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&consume/1)
  end

  def consume(line) do
    consume(line, [])
  end

  def consume("", acc), do: Enum.reverse(acc)

  def consume(<<c::binary-size(1)>>, acc) do
    consume("", [String.to_atom(c) | acc])
  end

  def consume(<<c::binary-size(1), d::binary-size(1), tail::binary>>, acc) do
    case c do
      l when l in ~w[e w] ->
        consume(d <> tail, [String.to_atom(l) | acc])

      _other ->
        consume(tail, [String.to_atom(c <> d) | acc])
    end
  end

  @deltas %{
    e: {1, 0},
    se: {0.5, -0.5},
    sw: {-0.5, -0.5},
    w: {-1, 0},
    nw: {-0.5, 0.5},
    ne: {0.5, 0.5}
  }

  def move(movements) do
    move(movements, {0, 0})
  end

  def move([], position), do: position

  def move([delta | tail], {x, y}) do
    {dx, dy} = @deltas[delta]

    move(tail, {x + dx, y + dy})
  end

  def paint_all(file) do
    file
    |> parse()
    |> Enum.reduce(%{}, fn movements, map ->
      target = move(movements)

      Map.update(map, target, :black, fn
        :white -> :black
        :black -> :white
      end)
    end)
  end
end

"input.txt"
|> Hex.paint_all()
|> Enum.count(&match?({_, :black}, &1))
|> IO.inspect()
