defmodule Camera do
  import Bitwise

  @monster [
    "                  # ",
    "#    ##    ##    ###",
    " #  #  #  #  #  #   "
  ]

  defmodule Picture do
    defstruct [:lines]

    def side(%__MODULE__{lines: lines}) do
      length(lines)
    end

    def new(lines) do
      %__MODULE__{lines: lines}
    end
  end

  defmodule Tile do
    @derive {Inspect, only: [:id, :borders]}

    defstruct [:id, :lines, :borders]

    def new(id, lines) do
      left = Camera.column(lines, 0)
      right = Camera.column(lines, length(lines) - 1)
      borders = [hd(lines), right, lines |> List.last(), left]

      %__MODULE__{id: id, lines: lines, borders: borders}
    end
  end

  def parse(file) do
    file
    |> File.read!()
    |> String.split("\n\n")
    |> Enum.map(fn tile ->
      [<<"Tile ", id::binary-size(4), ":">> | lines] = String.split(tile, "\n", trim: true)
      id = String.to_integer(id)

      lines =
        lines
        |> Enum.map(fn line ->
          line
          |> String.split("", trim: true)
          |> Enum.reduce(0, fn chr, acc ->
            (acc <<< 1) ^^^ if(chr == "#", do: 1, else: 0)
          end)
        end)

      Tile.new(id, lines)
    end)
  end

  def flip(%Tile{} = tile), do: Tile.new(tile.id, Enum.reverse(tile.lines))

  def flip(%Picture{} = picture), do: Picture.new(Enum.reverse(picture.lines))

  def rotate(%Tile{} = tile), do: Tile.new(tile.id, rotate(tile.lines))

  def rotate(%Picture{} = picture), do: Picture.new(rotate(picture.lines))

  def rotate(list) do
    Enum.map((length(list) - 1)..0, fn index ->
      column(list, index)
    end)
  end

  def variations(variable) do
    variable
    |> Stream.iterate(&rotate/1)
    |> Stream.take(4)
    |> Stream.concat(Stream.iterate(flip(variable), &rotate/1) |> Stream.take(4))
  end

  def column(lines, index) do
    max = length(lines) - 1

    Enum.reduce(lines, 0, fn line, acc ->
      acc <<< 1 ||| (line >>> (max - index) &&& 1)
    end)
  end

  def find_neighbor(tiles, target, target_border_index) do
    target_border = Enum.at(target.borders, target_border_index)

    tiles
    |> Stream.flat_map(fn {_id, tile} -> variations(tile) end)
    |> Enum.find(fn tile ->
      Enum.at(tile.borders, rem(target_border_index + 2, 4)) == target_border
    end)
    |> (fn
          nil -> nil
          tile -> {tile, Map.delete(tiles, tile.id)}
        end).()
  end

  def big_picture(map) do
    square_side = map |> map_size() |> :math.sqrt() |> floor()

    0..(square_side - 1)
    |> Enum.flat_map(fn y ->
      0..(square_side - 1)
      |> Enum.map(fn x ->
        map
        |> Map.get({x, y})
        |> Map.get(:lines)
        |> Enum.drop(1)
        |> Enum.take(8)
        |> Enum.map(fn line -> line >>> 1 &&& 0b11111111 end)
      end)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(fn line ->
        Enum.reduce(line, fn int, acc ->
          acc <<< 8 ||| int
        end)
      end)
    end)
    |> Picture.new()
  end

  def hunt(picture) do
    monster_size = @monster |> hd() |> String.length()
    side = Picture.side(picture)

    monster_mask =
      Enum.map(@monster, fn line ->
        line
        |> String.graphemes()
        |> Enum.reduce(0, fn chr, acc ->
          acc <<< 1 ||| if chr == "#", do: 1, else: 0
        end)
      end)

    picture
    |> variations()
    |> Enum.find_value(fn picture ->
      picture.lines
      |> Stream.zip(Stream.drop(picture.lines, 1))
      |> Stream.zip(Stream.drop(picture.lines, 2))
      |> Stream.map(fn {{a, b}, c} -> [a, b, c] end)
      |> Enum.reduce(0, fn lines, count ->
        0..(side - monster_size)
        |> Enum.count(fn shift ->
          lines
          |> Stream.map(&(&1 >>> shift))
          |> Stream.zip(monster_mask)
          |> Enum.reduce(true, fn {int, mask}, acc ->
            acc && (int &&& mask) == mask
          end)
        end)
        |> Kernel.+(count)
      end)
      |> (fn
            0 -> nil
            other -> other
          end).()
    end)
  end

  def roughness(picture) do
    roughness(picture, hunt(picture))
  end

  def roughness(picture, monsters) do
    side = Picture.side(picture)

    by_monster =
      @monster
      |> Enum.flat_map(&String.graphemes/1)
      |> Enum.count(fn chr -> chr == "#" end)

    picture.lines
    |> Enum.reduce(0, fn line, acc ->
      0..side
      |> Enum.reduce(0, fn shift, ones ->
        ones + (line >>> shift &&& 1)
      end)
      |> Kernel.+(acc)
    end)
    |> Kernel.-(monsters * by_monster)
  end

  def find_corners(tiles) do
    flip = fn
      _int, acc, 10, _then ->
        acc

      int, acc, count, then ->
        then.(int, acc <<< 1 ||| (int >>> count &&& 1), count + 1, then)
    end

    flipped = fn borders ->
      Enum.map(borders, &flip.(&1, 0, 0, flip))
    end

    corner_borders =
      tiles
      |> Enum.flat_map(fn {_id, tile} ->
        tile.borders ++ flipped.(tile.borders)
      end)
      |> Enum.frequencies()
      |> Enum.filter(&match?({_border, 1}, &1))
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()

    tiles
    |> Enum.filter(fn {_id, tile} ->
      4 ==
        tile.borders
        |> MapSet.new()
        |> MapSet.union(MapSet.new(flipped.(tile.borders)))
        |> MapSet.intersection(corner_borders)
        |> MapSet.size()
    end)
    |> Enum.into(%{})
  end

  def build_picture(input) do
    input
    |> build_map()
    |> big_picture()
  end

  def build_map(input) do
    tiles = input |> Camera.parse() |> Enum.into(%{}, fn tile -> {tile.id, tile} end)
    square_side = tiles |> map_size() |> :math.sqrt() |> floor()
    corner_tiles = find_corners(tiles)

    # "top left" corner
    corner =
      corner_tiles
      |> Enum.find(fn {_id, corner} ->
        find_neighbor(Map.delete(tiles, corner.id), corner, 0) == nil &&
          find_neighbor(Map.delete(tiles, corner.id), corner, 3) == nil
      end)
      |> elem(1)

    tiles = Map.delete(tiles, corner.id)
    map = %{{0, 0} => corner}

    0..(square_side - 1)
    |> Enum.reduce({map, tiles}, fn x, {map, tiles} ->
      map =
        Map.put_new_lazy(map, {x, 0}, fn ->
          tiles
          |> Camera.find_neighbor(map[{x - 1, 0}], 1)
          |> elem(0)
        end)

      tiles = Map.delete(tiles, map[{x, 0}].id)

      1..(square_side - 1)
      |> Enum.reduce({map, tiles}, fn y, {map, tiles} ->
        {tile, tiles} = find_neighbor(tiles, map[{x, y - 1}], 2)

        {Map.put(map, {x, y}, tile), tiles}
      end)
    end)
    |> elem(0)
  end
end

"input.txt"
|> Camera.build_picture()
|> Camera.roughness()
|> IO.inspect()
