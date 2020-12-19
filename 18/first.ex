defmodule Maths do
  defstruct [:value, left: nil, right: nil]

  def parse(expr) do
    char_stack = []
    node_stack = []

    expr
    |> tokenize()
    |> Enum.reduce({char_stack, node_stack}, fn
      "(", {cs, ns} ->
        {["(" | cs], ns}

      ")", {cs, ns} ->
        {[_ | cs], ns} = pop_nodes(cs, ns)

        {cs, ns}

      op, {cs, ns} when op in ["+", "*"] ->
        {cs, ns} = pop_nodes(cs, ns)

        {[op | cs], ns}

      operand, {cs, ns} ->
        node = %__MODULE__{value: operand}

        {cs, [node | ns]}
    end)
    |> (fn {cs, ns} -> pop_nodes(cs, ns) end).()
    |> (fn {_cs, [ns | _]} -> ns end).()
  end

  defp pop_nodes([], ns) do
    {[], ns}
  end

  defp pop_nodes(["(" | _] = cs, ns) do
    {cs, ns}
  end

  defp pop_nodes(cs, ns) do
    [token | cs] = cs
    [right | ns] = ns
    [left | ns] = ns

    node = %__MODULE__{value: token, left: left, right: right}

    pop_nodes(cs, [node | ns])
  end

  defp tokenize(expr) do
    expr
    |> String.graphemes()
    |> Enum.flat_map(fn
      chr when chr in [" ", "\n"] ->
        []

      term ->
        [term]
    end)
  end

  def solve(%__MODULE__{left: nil, right: nil, value: v}), do: String.to_integer(v)

  def solve(%__MODULE__{value: op, left: left, right: right}) do
    %{"+" => &Kernel.+/2, "*" => &Kernel.*/2}
    |> Map.get(op)
    |> apply([solve(left), solve(right)])
  end
end

ExUnit.start()

defmodule MathsTest do
  use ExUnit.Case

  test "sample inputs" do
    assert 26 = solve("2 * 3 + (4 * 5)")
    assert 437 = solve("5 + (8 * 3 + 9 + 3 * 4 * 3)")
    assert 12240 = solve("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))")
    assert 13632 = solve("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2")
  end

  test "solves first star" do
    assert 53_660_285_675_207 =
             "input.txt"
             |> File.stream!()
             |> Stream.map(&Maths.parse/1)
             |> Stream.map(&Maths.solve/1)
             |> Enum.sum()
  end

  defp solve(str) do
    str
    |> Maths.parse()
    |> Maths.solve()
  end
end
