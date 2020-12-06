require 'set'

puts 6763 == File
  .read("input.txt")
  .split(/\n\n/)
  .map { |group|
    Set.new(group.lines.map(&:strip).flat_map(&:chars))
  }
    .tap  { |e| puts e.inspect }
    .map(&:length)
    .tap  { |e| puts e.inspect }
    .reduce(&:+)
