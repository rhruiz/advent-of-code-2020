map = File.open("input.txt").each_line.map do |line|
  line.strip.chars
end

width = map[0].length
height = map.length

puts (1...height).select { |line| map[line][line*3 % width] == "#" }.size
