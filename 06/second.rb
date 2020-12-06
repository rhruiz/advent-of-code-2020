require 'set'
require 'minitest/unit'

def count_all_yes(file)
  File
    .read(file)
    .split(/\n\n/)
    .map { |group|
      answers = group.lines.map(&:strip).map(&:chars)

      [answers.length, answers.each_with_object(Hash.new { |_key| 0 }) do |answer, acc|
        answer.each { |letter| acc[letter] += 1 }
      end]
    }
    .map { |(size, answers)| answers.keep_if { |_letter, count| count == size } }
    .map(&:length)
    .reduce(&:+)
end

class CountAllYes < Minitest::Test
  def test_with_sample_input
    assert_equal 6, count_all_yes("input.sample.txt")
  end

  def test_with_input
    assert_equal 3512, count_all_yes("input.txt")
  end
end
