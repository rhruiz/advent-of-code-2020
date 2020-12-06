require 'set'
require 'minitest/unit'

def count_yes_anwers(file)
  File
    .read(file)
    .split(/\n\n/)
    .map { |group| Set.new(group.lines.map(&:strip).flat_map(&:chars)) }
    .map(&:length)
    .reduce(&:+)
end


class YesCounterTest < Minitest::Test
  def test_with_sample_input
    assert_equal 11, count_yes_anwers("input.sample.txt")
  end

  def test_with_input
    assert_equal 6763, count_yes_anwers("input.txt")
  end
end
