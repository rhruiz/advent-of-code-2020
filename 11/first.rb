def parse(input)
  Hash[
    File.open(input, 'r').each_line.each_with_index
    .map { |line, index| [index, Hash[line.strip.chars.each_with_index.map { |tile, index| [index, tile] }]] }]
end

DELTAS =
  [
    [-1, -1], [0, -1], [1, -1],
    [-1, 0], [1, 0],
    [-1, 1], [0, 1], [1, 1]
  ]

def occ?(map, (x, y))
  (map[y] || [])[x] == "#"
end

def empty?(map, (x, y))
  (map[y] || [])[x] == "L"
end

def floor?(map, (x, y))
  (map[y] || [])[x] == "."
end

def apply((x, y), (dx, dy))
  [x+dx, y+dy]
end

def occ_around(map, position)
  DELTAS.select { |delta| occ?(map, apply(position, delta)) }.count
end

def state(map)
  map
end

def render(map)
  map.values.each { |line| puts line.values.join("") }
  puts ""
  puts "*" * map.first.length
  puts ""
end

map = parse('input.sample.txt')
map = parse('input.txt')
state = state(map)

rounds = 0

loop do
  render(map)
  rounds = rounds + 1
  new_map = map.each_with_object({}) { |(k, v), acc| acc[k] = v.dup }

  map.keys.each do |y|
    map[y].keys.each do |x|
      tile = map[y][x]
      next if tile == "."

      if empty?(map, [x, y]) && occ_around(map, [x, y]) == 0
        new_map[y][x] = "#"
      end

      if occ?(map, [x, y]) && occ_around(map, [x, y]) >= 4
        new_map[y][x] = "L"
      end
    end
  end

  new_state = state(new_map)
  map = new_map
  break if new_state == state

  state = new_state
end

puts rounds

puts map.values.flatten.map(&:values).flatten.select { |value| value == "#" }.count
