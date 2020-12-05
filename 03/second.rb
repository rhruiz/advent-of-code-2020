map = File.open("input.txt").each_line.map do |line|
  line.strip.chars
end

width = map[0].length
height = map.length

steps = [
  [1, 1],
  [3, 1],
  [5, 1],
  [7, 1],
  [1, 2]
]

puts(steps.map do |(x, y)|
  (0...height).step(y).select { |line| map[line][line*x/y % width] == "#" }.size
end.reduce(&:*))
