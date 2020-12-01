require 'set'

numbers = []

File.open("input.txt", "r").each_line do |line|
  numbers << line.strip.to_i
end

puts numbers
  .combination(3)
  .find { |set| set.reduce(&:+) == 2020 }
  .reduce(&:*)

