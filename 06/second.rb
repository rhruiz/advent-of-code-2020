require 'set'

puts 3512 == File
  .read("input.txt")
  .split(/\n\n/)
  .map { |group|
    answers = group.lines.map(&:strip).map(&:chars)

    [answers.length, answers.each_with_object(Hash.new { |_key| 0 }) do |answer, acc|
      answer.each { |letter| acc[letter] += 1 }
    end]
  }
    .map { |(size, answers)| answers.keep_if { |_letter, count| count == size } }
    .tap  { |e| puts e.inspect }
    .map(&:length)
    .tap  { |e| puts e.inspect }
    .reduce(&:+)
