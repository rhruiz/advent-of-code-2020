defmodule Ferry do
  @facing %{
    e: {1, 0},
    n: {0, 1},
    w: {-1, 0},
    s: {0, -1}
  }

  def initial, do: {@facing[:e], {0, 0}}

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

  def move({{fx, fy}, {x, y}}, {:f, amount}) do
    dx = fx * amount
    dy = fy * amount

    {{fx, fy}, {x + dx, y + dy}}
  end

  def move({facing, {x, y}}, {direction, amount}) do
    {dx, dy} =
      @facing
      |> Map.fetch!(direction)
      |> Tuple.to_list()
      |> Enum.map(fn delta -> delta * amount end)
      |> List.to_tuple()

    {facing, {x + dx, y + dy}}
  end

  defp phase({1, 0}), do: 0
  defp phase({0, 1}), do: 90
  defp phase({-1, 0}), do: 180
  defp phase({0, -1}), do: 270

  defp phase(0), do: {1, 0}
  defp phase(90), do: {0, 1}
  defp phase(180), do: {-1, 0}
  defp phase(270), do: {0, -1}

  def rotate({facing, position}, {direction, amount}) do
    sign = if(direction == :l, do: 1, else: -1)
    facing = phase(rem(phase(facing) + sign * amount + 360, 360))

    {facing, position}
  end

  def rotate({{x, y}, position}, {_direction, 180}) do
    {{x * -1, y * -1}, position}
  end

  def apply(state, {instruction, amount}) when instruction in [:r, :l] do
    rotate(state, {instruction, amount})
  end

  def apply(state, instruction) do
    move(state, instruction)
  end
end

"input.txt"
|> Ferry.parse()
|> Enum.reduce(Ferry.initial(), fn instruction, state ->
  Ferry.apply(state, instruction) |> IO.inspect(label: inspect(instruction))
end)
|> elem(1)
|> Tuple.to_list()
|> Enum.reduce(0, fn part, acc -> acc + abs(part) end)
|> IO.inspect()
