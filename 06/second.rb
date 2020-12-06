require 'set'
require 'minitest/unit'

def frequencies(hash)
  hash.each_with_object(Hash.new { |_key| 0 }) do |key, acc|
    acc[key] += 1
  end
end

def count_all_yes(file)
  File
    .open(file, 'r')
    .chunk_while { |fc, sc| fc != "\n" && sc != "\n" }
    .reject { |e| e == ["\n"] }
    .map { |group| [group.length, frequencies(group.flat_map { |ans| ans.strip.chars })] }
    .map { |(size, answers)| answers.keep_if { |_letter, count| count == size } }
    .reduce(0) { |count, all_yes| count + all_yes.length }
end

class CountAllYes < Minitest::Test
  def test_with_sample_input
    assert_equal 6, count_all_yes("input.sample.txt")
  end

  def test_with_input
    assert_equal 3512, count_all_yes("input.txt")
  end
end
