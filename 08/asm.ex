defmodule Asm do
  @moduledoc """
  A very simple virtual machine
  """

  @type t :: map()
  @type number :: non_neg_integer()
  @type instruction :: {atom(), integer()}

  @spec parse(String.t()) :: t()
  def parse(file) do
    file
    |> File.stream!()
    |> Stream.with_index()
    |> Enum.into(%{}, fn {line, index} ->
      [op, value] =
        line
        |> String.trim()
        |> String.split(" ")

      {index, {String.to_atom(op), String.to_integer(value)}}
    end)
  end

  defp visit(visited, index) do
    Map.update(visited, index, 1, fn count -> count + 1 end)
  end

  @spec at(t(), number()) :: instruction()
  def at(program, line) do
    Map.get(program, line)
  end

  @spec run(t()) :: {:ok, integer()} | {:error, reason :: atom(), line(), integer()}
  def run(program) do
    run_program(program, 0, 0, %{})
  end

  defp run_program(program, index, acc, visited) do
    visited = visit(visited, index)

    case {Map.get(visited, index), at(program, index)} do
      {_, nil} ->
        {:ok, acc}

      {n, _} when n > 1 ->
        {:error, :loop, index, acc}

      {_, {:nop, _}} ->
        run_program(program, index + 1, acc, visited)

      {_, {:acc, value}} ->
        run_program(program, index + 1, acc + value, visited)

      {_, {:jmp, delta}} ->
        run_program(program, index + delta, acc, visited)
    end
  end

  @spec patch(t(), line()) :: t()
  def patch(program, index) do
    Map.update!(program, index, fn
      {:jmp, value} -> {:nop, value}
      {:nop, value} -> {:jmp, value}
      other -> other
    end)
  end
end
