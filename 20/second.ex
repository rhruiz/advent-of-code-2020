defmodule Camera do
  import Bitwise

  @monster [
    "                  # ",
    "#    ##    ##    ###",
    " #  #  #  #  #  #   "
  ]

  defmodule Picture do
    defstruct [:lines]

    def variations(picture) do
      picture
      |> Stream.iterate(&rotate/1)
      |> Stream.take(4)
      |> Stream.concat(Stream.iterate(flip(picture), &rotate/1) |> Stream.take(4))
    end

    def side(%__MODULE__{lines: lines}) do
      length(lines)
    end

    def render(%__MODULE__{lines: lines} = picture) do
      lines
      |> Enum.map(fn int ->
        int
        |> Integer.to_string(2)
        |> String.pad_leading(side(picture), "0")
      end)
      |> Enum.join("\n")
      |> String.replace("0", ".")
      |> String.replace("1", "#")
      |> IO.puts()
    end

    def column(%__MODULE__{lines: lines}, index) do
      column(lines, index)
    end

    def column(lines, index) do
      max = length(lines) - 1

      Enum.reduce(lines, 0, fn line, acc ->
        acc <<< 1 ||| (line >>> (max - index) &&& 1)
      end)
    end

    def rotate(picture) do
      max = length(picture.lines) - 1

      new(
        Enum.map(max..0, fn index ->
          column(picture, index)
        end)
      )
    end

    def flip(picture) do
      new(Enum.reverse(picture.lines))
    end

    def new(lines) do
      %__MODULE__{lines: lines}
    end
  end

  defmodule Tile do
    @derive {Inspect, only: [:id, :borders]}
    @max 9

    defstruct [:id, :lines, :borders, :borders_flipped]

    def vflip(tile) do
      new(tile.id, Enum.reverse(tile.lines))
    end

    def borders(tile), do: tile.borders

    def rotate(tile) do
      max = length(tile.lines) - 1

      new(
        tile.id,
        Enum.map(max..0, fn index ->
          column(tile, index)
        end)
      )
    end

    def column(%__MODULE__{lines: lines}, index) do
      column(lines, index)
    end

    def column(lines, index) do
      max = length(lines) - 1

      Enum.reduce(lines, 0, fn line, acc ->
        acc <<< 1 ||| (line >>> (max - index) &&& 1)
      end)
    end

    def new(id, lines) do
      left = column(lines, 0)
      right = column(lines, length(lines) - 1)
      borders = [hd(lines), right, lines |> List.last(), left]
      borders_flipped = Enum.map(borders, &flip/1)

      %__MODULE__{id: id, lines: lines, borders: borders, borders_flipped: borders_flipped}
    end

    def flip(int), do: flip(int, 0, 0)

    def flip(_int, acc, count) when count > @max, do: acc

    def flip(int, acc, count) do
      flip(int, acc <<< 1 ||| (int >>> count &&& 1), count + 1)
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
            (acc <<< 1) ^^^ if chr == "#", do: 1, else: 0
          end)
        end)

      Tile.new(id, lines)
    end)
  end

  def variations(tile) do
    tile
    |> Stream.iterate(&Tile.rotate/1)
    |> Stream.take(4)
    |> Stream.concat(Stream.iterate(Tile.vflip(tile), &Tile.rotate/1) |> Stream.take(4))
  end

  def find_candidate(tiles, used, target, target_border_index) do
    target_border = Enum.at(target.borders, target_border_index)

    tiles
    |> Stream.flat_map(fn {_id, tile} ->
      if tile.id in used do
        []
      else
        variations(tile)
      end
    end)
    |> Enum.find(fn tile ->
      Enum.at(tile.borders, rem(target_border_index + 2, 4)) == target_border
    end)
    |> (fn
          nil -> nil
          tile -> {tile.id, Map.put(tiles, tile.id, tile)}
        end).()
  end

  def big_picture(tiles, map, square_side) do
    0..(square_side - 1)
    |> Enum.flat_map(fn y ->
      0..(square_side - 1)
      |> Enum.map(fn x ->
        tiles
        |> Map.get(map[{x, y}])
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

  def render_line(int, size) do
    int |> Integer.to_string(2) |> String.pad_leading(size, "0")
  end

  def hunt(picture) do
    bit_size = String.length(hd(@monster))
    side = Picture.side(picture)

    monster_mask =
      Enum.map(@monster, fn line ->
        line
        |> String.graphemes()
        |> Enum.reduce(0, fn chr, acc ->
          acc <<< 1 ||| (if chr == "#", do: 1, else: 0)
        end)
      end)

    picture
    |> Picture.variations()
    |> Enum.find_value(fn picture ->
      picture.lines
      |> Stream.zip(Stream.drop(picture.lines, 1))
      |> Stream.zip(Stream.drop(picture.lines, 2))
      |> Stream.map(fn {{a, b}, c} -> [a, b, c] end)
      |> Enum.reduce(0, fn lines, count ->
        0..(side - bit_size)
        |> Enum.count(fn shift ->
          lines
          |> Enum.map(&(&1 >>> shift))
          |> Enum.zip(monster_mask)
          |> Enum.reduce(true, fn {int, mask}, acc ->
            acc && ((int &&& mask) == mask)
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

  def roughness(picture, monsters) do
    side = Picture.side(picture)

    by_monsters =
      @monster
      |> Enum.flat_map(&String.graphemes/1)
      |> Enum.count(fn chr -> chr == "#" end)

    picture.lines
    |> Enum.reduce(0, fn line, acc ->
      0..side
      |> Enum.reduce(0, fn shift, ones ->
        ones + ((line >>> shift) &&& 1)
      end)
      |> Kernel.+(acc)
    end)
    |> Kernel.-(monsters * by_monsters)
  end
end

tiles = "input.txt" |> Camera.parse() |> Enum.into(%{}, fn tile -> {tile.id, tile} end)

square_side = tiles |> map_size() |> :math.sqrt() |> floor()

corner_borders =
  tiles
  |> Enum.flat_map(fn {_id, tile} -> tile.borders ++ tile.borders_flipped end)
  |> Enum.frequencies()
  |> Enum.filter(&match?({_border, 1}, &1))
  |> Enum.map(&elem(&1, 0))
  |> MapSet.new()

corner_tiles =
  tiles
  |> Enum.filter(fn {_id, tile} ->
    4 ==
      tile.borders
      |> MapSet.new()
      |> MapSet.union(MapSet.new(tile.borders_flipped))
      |> MapSet.intersection(corner_borders)
      |> MapSet.size()
  end)
  |> Enum.into(%{})

corner =
  corner_tiles
  |> Enum.find(fn {_id, corner} ->
    Camera.find_candidate(tiles, MapSet.new([corner.id]), corner, 0) == nil &&
      Camera.find_candidate(tiles, MapSet.new([corner.id]), corner, 3) == nil
  end)
  |> elem(1)

tiles = Map.put(tiles, corner.id, corner)
used = MapSet.new([corner.id])
map = %{{0, 0} => corner.id}

{tiles, used, map} =
  1..(square_side - 1)
  |> Enum.reduce({tiles, used, map}, fn n, {tiles, used, map} ->
    position = {0, n}
    {id, tiles} = Camera.find_candidate(tiles, used, tiles[map[{0, n - 1}]], 2)
    map = Map.put(map, position, id)

    {tiles, MapSet.put(used, id), map}
  end)

{tiles, _used, map} =
  Enum.reduce(1..(square_side - 1), {tiles, used, map}, fn x, {tiles, used, map} ->
    {id, tiles} = Camera.find_candidate(tiles, used, tiles[map[{x - 1, 0}]], 1)
    map = Map.put(map, {x, 0}, id)
    used = MapSet.put(used, id)

    1..(square_side - 1)
    |> Enum.reduce({tiles, used, map}, fn y, {tiles, used, map} ->
      position = {x, y}
      {id, tiles} = Camera.find_candidate(tiles, used, tiles[map[{x, y - 1}]], 2)
      map = Map.put(map, position, id)

      {tiles, MapSet.put(used, id), map}
    end)
  end)

picture = Camera.big_picture(tiles, map, square_side)
monsters = Camera.hunt(picture)

picture
|> Camera.roughness(monsters)
|> IO.inspect()
