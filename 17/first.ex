defmodule Conway do
  defstruct [:map, :xmax, :ymax, :zmax]

  def parse(file) do
    {max, map} =
      file
      |> File.stream!()
      |> Enum .with_index()
      |> Enum.reduce({0, %{}}, fn {line, y}, {_max, acc} ->
        {
          y,
          line
          |> String.trim()
          |> String.split("", trim: true)
          |> Enum.with_index()
          |> Enum.into(acc, fn {chr, x} -> {{x, y, 0}, chr} end)
        }
      end)

    %__MODULE__{
      map: map,
      xmax: max,
      ymax: max,
      zmax: 0
    }
  end

  def at(%__MODULE__{map: map}, {x, y, z}) do
    Map.get(map, {x, y, z}, ".")
  end

  def put(%__MODULE__{map: map} = game, {x, y, z} = position, value) do
    %{game |
      map: Map.put(map, position, value),
      xmax: max(game.xmax, abs(x)),
      ymax: max(game.ymax, abs(y)),
      zmax: max(game.zmax, abs(z))}
  end

  def neighbors(game, {x, y, z}) do
    for zn <- (z - 1)..(z + 1),
        yn <- (y - 1)..(y + 1),
        xn <- (x - 1)..(x + 1),
        {x, y, z} != {xn, yn, zn} do
      at(game, {xn, yn, zn})
    end
  end

  def active_neighbors(game, position) do
    game
    |> neighbors(position)
    |> Enum.count(fn value -> value == "#" end)
  end

  def render(%__MODULE__{} = game) do
    game
    |> all_coords()
    |> Enum.chunk_by(&elem(&1, 2))
    |> Enum.each(fn ys ->
      IO.puts("z=#{ys |> hd() |> elem(2)}")

      ys
      |> Enum.chunk_by(&elem(&1, 1))
      |> Enum.each(fn xs ->
        xs |> Enum.map(fn position -> at(game, position) end) |> IO.puts
      end)
    end)
  end

  defp all_coords(game) do
    for z <- (-game.zmax-1)..(game.zmax+1),
      y <- (-game.ymax-1)..(game.ymax+1),
      x <- (-game.xmax-1)..(game.xmax+1) do
      {x, y, z}
    end
  end

  def actives(game) do
    game
    |> all_coords()
    |> Enum.count(fn coord -> at(game, coord) == "#" end)
  end

  def cycle(%__MODULE__{} = game) do
    game
    |> all_coords()
    |> Enum.reduce(game, fn position, new_game ->
      case {at(game, position), active_neighbors(game, position)} do
        {"#", n} when n not in [2, 3] -> put(new_game, position, ".")
        {".", 3} -> put(new_game, position, "#")
        _ -> new_game
      end
    end)
  end
end

ExUnit.start()

defmodule ConwayTest do
  use ExUnit.Case

  test "computes active cubes on test input after six cycles" do
    assert 112 = actives("input.sample.txt")
  end

  test "computes active cubes on input after six cycles" do
    assert 382 = actives("input.txt")
  end

  def actives(file) do
    file
    |> Conway.parse()
    |> Stream.iterate(&Conway.cycle/1)
    |> Stream.drop(6)
    |> Enum.take(1)
    |> hd()
    |> Conway.actives()
  end
end
