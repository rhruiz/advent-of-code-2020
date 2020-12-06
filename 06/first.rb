require 'set'
require 'minitest/unit'

def count_yes_anwers(file)
  File
    .open(file, 'r')
    .chunk_while { |fc, sc| fc != "\n" && sc != "\n" }
    .reject { |e| e == ["\n"] }
    .reduce(0) { |count, group| count + Set.new(group.flat_map { |ans| ans.strip.chars }).length }
end

class YesCounterTest < Minitest::Test
  def test_with_sample_input
    assert_equal 11, count_yes_anwers("input.sample.txt")
  end

  def test_with_input
    assert_equal 6763, count_yes_anwers("input.txt")
  end
end
