defmodule Rules do
  def parse(file) do
    [rules, messages] = file |> File.read!() |> String.split("\n\n", parts: 2)

    {parse_rules(rules), parse_messages(messages)}
  end

  defp parse_messages(messages) do
    messages
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
  end

  defp parse_rules(rules) do
    rules
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.into(%{}, fn line ->
      [id, terms] = String.split(line, ": ")

      {String.to_integer(id), parse_terms(terms)}
    end)
  end

  defp parse_terms(<< "\"", chr::binary-size(1), "\"">>) do
    {:chr, chr}
  end

  defp parse_terms(terms) do
    {:or,
      terms
      |> String.split(" | ")
      |> Enum.map(fn term ->
        term
        |> String.split(" ")
        |> (fn rules ->
          {:and, Enum.map(rules, &String.to_integer/1)}
        end).()
      end)
    }
  end

  def apply(all_rules, rule, message) when is_binary(message) do
    case __MODULE__.apply(all_rules, rule, String.graphemes(message)) do
      {true, [_message | _]} -> false
      {true, []} -> true
      false -> false
    end
  end

  def apply(_all_rules, [], [_message | _]), do: false
  def apply(_all_rules, [_rule | _], []), do: false

  def apply(all_rules, {:and, terms}, message) do
    Enum.reduce(terms, {true, message}, fn
      _term, false ->
        false

      term, {true, message} ->
        __MODULE__.apply(all_rules, all_rules[term], message)
    end)
  end

  def apply(all_rules, {:or, terms}, message) do
    Enum.reduce(terms, false, fn
      term, false ->
        __MODULE__.apply(all_rules, term, message)

      _term, {true, message} ->
        {true, message}
    end)
  end

  def apply(_all_rules, {:chr, chr}, [chr | tail]) do
    {true, tail}
  end

  def apply(_all_rules, {:chr, _chr}, _message) do
    false
  end
end

{rules, messages} = Rules.parse("input.txt")

messages
|> Enum.filter(fn message -> Rules.apply(rules, rules[0], message) end)
|> IO.inspect()
|> length()
|> IO.puts()
