defmodule Camera do
  import Bitwise

  defmodule Tile do
    @size 10

    defstruct [:id, :lines, :borders, :borders_flipped]

    def hflip(tile) do
      new(tile.id, Enum.map(tile.lines, &flip/1))
    end

    def rotate(tile) do
      new(
        tile.id,
        Enum.map(0..(@size - 1), fn index ->
          column(tile, index)
        end)
      )
    end

    def column(%__MODULE__{lines: lines}, index) do
      column(lines, index)
    end

    def column(lines, index) do
      Enum.reduce(lines, 0, fn line, acc ->
        acc <<< 1 ||| (line >>> index &&& 1)
      end)
    end

    def new(id, lines) do
      left = column(lines, @size - 1)
      right = column(lines, 0)
      borders = [hd(lines), right, List.last(lines), left]
      borders_flipped = Enum.map(borders, &flip/1)

      %__MODULE__{id: id, lines: lines, borders: borders, borders_flipped: borders_flipped}
    end

    def flip(int), do: flip(int, 0, 0)

    def flip(_int, acc, @size), do: acc

    def flip(int, acc, count) do
      flip(int, acc <<< 1 ||| (int >>> count &&& 1), count + 1)
    end
  end

  defimpl Inspect, for: Tile do
    import Inspect.Algebra

    @size 10

    def inspect(tile, _opts) do
      concat([
        "Tile #{tile.id}:\n",
        tile.lines
        |> Enum.map(fn line -> int_to_line(line, [], 0) end)
        |> Enum.join("\n")
      ])
    end

    defp int_to_line(_int, acc, @size), do: to_string([acc])

    defp int_to_line(int, acc, count) do
      chr = if((int >>> count &&& 1) == 1, do: "#", else: ".")

      int_to_line(int, [chr | acc], count + 1)
    end
  end

  def parse(file) do
    file
    |> File.read!()
    |> String.split("\n\n")
    |> Enum.map(fn tile ->
      [<<"Tile ", id::binary-size(4), ":">> | lines] = String.split(tile, "\n")
      id = String.to_integer(id)

      lines =
        lines
        |> Enum.map(fn line ->
          line
          |> String.split("", trim: true)
          |> Enum.reduce(0, fn chr, acc ->
            (acc <<< 1) ^^^ if chr == "#", do: 1, else: 0
          end)
        end)

      Tile.new(id, lines)
    end)
  end
end

tiles = "input.txt" |> Camera.parse() |> Enum.into(%{}, fn tile -> {tile.id, tile} end)

corner_borders =
  tiles
  |> Enum.flat_map(fn {_id, tile} -> tile.borders ++ tile.borders_flipped end)
  |> Enum.frequencies()
  |> Enum.filter(&match?({_border, 1}, &1))
  |> Enum.map(&elem(&1, 0))
  |> MapSet.new()

tiles
|> Enum.filter(fn {_id, tile} ->
  4 ==
    tile.borders
    |> MapSet.new()
    |> MapSet.union(MapSet.new(tile.borders_flipped))
    |> MapSet.intersection(corner_borders)
    |> MapSet.size()
end)
|> Enum.map(&elem(&1, 0))
|> Enum.reduce(1, &Kernel.*/2)
|> IO.inspect()
