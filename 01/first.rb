require 'set'

numbers = []

File.open("input.txt", "r").each_line do |line|
  numbers << line.strip.to_i
end

puts numbers
  .combination(2)
  .find { |set| set.reduce(&:+) == 2020 }
  .reduce(&:*)
