require 'minitest/unit'
require 'set'

def parse(file)
  (validation,  my, others) = File.read(file).split(/\n\n/)

  validation = validation.split(/\n/).each_with_object({}) do |line, acc|
    (field, ranges) = line.split(': ')

    ranges = ranges.split(' or ').map { |range| Range.new(*range.split('-').map(&:to_i)) }

    acc[field] = ranges
  end

  my = my.lines.drop(1).first.split(",").map(&:to_i)
  others = others.lines.drop(1).map { |line| line.split(",").map(&:to_i) }

  [validation, my, others]
end

def invalid?(ticket, validation)
  invalid_values(ticket, validation).any?
end

def invalid_values(ticket, validation)
  all_ranges = validation.values.flatten

  ticket.lazy.select { |number| all_ranges.all? { |range| !range.member?(number) } }
end

def error_rate(tickets, validation)
  tickets.reduce(0) do |acc, ticket|
    acc + invalid_values(ticket, validation).sum
  end
end

def find_field_order(validation, tickets, length)
    possibilities = (0...length).to_a.map do |position|
      [position, Set.new(validation.keys.select do |field|
        tickets.all? do |ticket|
          validation[field].any? { |range| range.member?(ticket[position]) }
        end
      end)]
    end

    figure_out_fields(possibilities.sort_by { |e| e.last.length }, {})
end

def figure_out_fields(possibilities, certain)
  return certain if possibilities.empty?

  (position, fields) = possibilities.shift

  if fields.length == 1
    certain[fields.first] = position
    possibilities.each { |(pos, possible_fields)| possible_fields.delete(fields.first) }
  else
    possibilities.push(poss)
  end

  figure_out_fields(possibilities, certain)
end

class ValidationTest < Minitest::Test
  def test_sample_input_valid_tickets
    validation = parse('input.sample.txt').first

    refute invalid?([7,3,47], validation)
    assert invalid?([40,4,50], validation)
    assert invalid?([55,2,20], validation)
    assert invalid?([38,6,12], validation)
  end

  def test_sample_input_error_rate
    validation = parse('input.sample.txt').first
    tickets = [[7,3,47], [40,4,50], [55,2,20], [38,6,12]]

    assert_equal 71, error_rate(tickets, validation)
  end

  def test_input_error_rate
    (validation, _my, others) = parse('input.txt')

    assert_equal 26941, error_rate(others, validation)
  end

  def test_sample_input_fields
    (validation, my, others) = parse('input.sample2.txt')

    others.reject! { |ticket| invalid?(ticket, validation) }

    positions = find_field_order(validation, others, my.length)

    assert_equal({'class' => 12, 'row' => 11, 'seat' => 13}, positions.map do |(field, position)|
      [field, my[position]]
    end.to_h)
  end

  def test_my_departure_fields
    (validation, my, others) = parse('input.txt')
    others.reject! { |ticket| invalid?(ticket, validation) }

    positions = find_field_order(validation, others, my.length)

    assert_equal 634796407951, positions
      .keep_if { |key, _value| key.start_with?("departure") }
      .map { |(_field, position)| my[position] }.reduce(&:*)
  end
end
