ExUnit.start()

defmodule Ferry do
  @facing %{
    e: {1, 0},
    n: {0, 1},
    w: {-1, 0},
    s: {0, -1}
  }

  def initial, do: {{0, 0}, {10, 1}}

  def parse(file) do
    file
    |> File.stream!()
    |> Stream.map(fn line ->
      [direction, amount] =
        line
        |> String.trim()
        |> String.split("", parts: 2, trim: true)

      direction = direction |> String.downcase() |> String.to_atom()
      amount = String.to_integer(amount)

      {direction, amount}
    end)
  end

  def move({{x, y}, {wx, wy}}, {:f, amount}) do
    dx = wx * amount
    dy = wy * amount

    {{x + dx, y + dy}, {wx, wy}}
  end

  def move({position, {wx, wy}}, {direction, amount}) do
    {dx, dy} =
      @facing
      |> Map.fetch!(direction)
      |> Tuple.to_list()
      |> Enum.map(fn delta -> delta * amount end)
      |> List.to_tuple()

    {position, {wx + dx, wy + dy}}
  end

  def rotate({position, {wx, wy}}, {_direction, 180}) do
    {position, {wx * -1, wy * -1}}
  end

  def rotate(state, {direction, 270}) do
    state
    |> rotate({direction, 90})
    |> rotate({direction, 180})
  end

  def rotate({position, {wx, wy}}, {direction, 90}) do
    rotations = %{
      {1, 1} => {-1, 1},
      {-1, 1} => {-1, -1},
      {-1, -1} => {1, -1},
      {1, -1} => {1, 1},
      {1, 0} => {1, 0},
      {0, 1} => {0, -1},
      {-1, 0} => {-1, 0},
      {0, -1} => {0, 1},
      {0, 0} => {0, 0}
    }

    normalize = fn
      0 -> 1
      n -> floor(n / abs(n))
    end

    sign = if(direction == :l, do: 1, else: -1)

    {fx, fy} = Map.get(rotations, {normalize.(wx), normalize.(wy)})

    {position, {abs(wy) * fx * sign, abs(wx) * fy * sign}}
  end

  def apply(state, {instruction, amount}) when instruction in [:r, :l] do
    rotate(state, {instruction, amount})
  end

  def apply(state, instruction) do
    move(state, instruction)
  end
end

defmodule FerryTest do
  use ExUnit.Case

  test "rotates (-7+2i) 90 to the right" do
    assert {{0, 0}, {-7, 2}} |> Ferry.rotate({:r, 90}) == {{0, 0}, {2, 7}}
  end

  test "rotates (-7+2i) 270 to the left" do
    assert {{0, 0}, {-7, 2}} |> Ferry.rotate({:l, 270}) == {{0, 0}, {2, 7}}
  end

  test "rotates (-7-2i) 90 to the left" do
    assert {{0, 0}, {-7, -2}} |> Ferry.rotate({:l, 90}) == {{0, 0}, {2, -7}}
  end

  test "rotates (7-2i) 90 to the left" do
    assert {{0, 0}, {7, -2}} |> Ferry.rotate({:l, 90}) == {{0, 0}, {2, 7}}
  end

  test "rotates (7+2i) 90 to the left" do
    assert {{0, 0}, {7, 2}} |> Ferry.rotate({:l, 90}) == {{0, 0}, {-2, 7}}
  end

  test "rotates (-25+5i) 180 to the left" do
    assert {{0, 0}, {-25, 5}} |> Ferry.rotate({:l, 180}) == {{0, 0}, {25, -5}}
  end

  test "rotates (-25+5i) 180 to the right" do
    assert {{0, 0}, {-25, 5}} |> Ferry.rotate({:l, 180}) == {{0, 0}, {25, -5}}
  end

  describe "rotates on axis" do
    @facing %{
      e: {1, 0},
      n: {0, 1},
      w: {-1, 0},
      s: {0, -1}
    }

    Enum.map(%{e: :n, n: :w, w: :s, s: :e}, fn {from, to} ->
      test "rotates from #{from} to #{to}" do
        assert Ferry.rotate({{0, 0}, @facing[unquote(from)]}, {:l, 90}) ==
                 {{0, 0}, @facing[unquote(to)]}
      end
    end)
  end

  describe "star" do
    test "distance is 286 with sample data" do
      assert 286 == distance("input.sample.txt")
    end

    test "distance is 62045 with input data" do
      assert 62045 == distance("input.txt")
    end

    def distance(file) do
      file
      |> Ferry.parse()
      |> Enum.reduce(Ferry.initial(), fn instruction, state ->
        Ferry.apply(state, instruction)
      end)
      |> elem(0)
      |> Tuple.to_list()
      |> Enum.reduce(0, fn part, acc -> acc + abs(part) end)
    end
  end
end
