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

  def blacks(map) do
    Enum.count(map, &match?({_, :black}, &1))
  end

  def expand(map, {x, y}) do
    @deltas
    |> Map.values()
    |> Enum.reduce(map, fn {dx, dy}, map ->
      Map.put_new(map, {x + dx, y + dy}, :white)
    end)
  end

  def black_neighbors(map, {x, y}) do
    @deltas
    |> Map.values()
    |> Enum.count(fn {dx, dy} ->
      Map.get(map, {x + dx, y + dy}) == :black
    end)
  end

  def flip_all(map) do
    map
    |> Enum.reduce(map, fn {position, _color}, map ->
      expand(map, position)
    end)
    |> Enum.into(%{}, fn {position, color} ->
      case {color, black_neighbors(map, position)} do
        {:black, n} when n == 0 or n > 2 -> {position, :white}
        {:white, 2} -> {position, :black}
        {color, _} -> {position, color}
      end
    end)
  end
end

map = Hex.paint_all("input.txt")

0..99
|> Enum.reduce(map, fn _day, map -> Hex.flip_all(map) end)
|> Hex.blacks()
|> IO.puts()
