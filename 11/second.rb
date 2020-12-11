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
  _acc_arround(map, position, DELTAS, [])
end

def _acc_arround(map, position, deltas, occ)
  return occ.length if deltas.empty?

  (more_occ, left) = deltas.partition do |delta|
    occ?(map, apply(position, delta))
  end

  new_deltas = left
    .reject { |delta| empty?(map, apply(position, delta)) }
    .map { |delta| delta.map { |n| n == 0  ? 0 : n+(n/n.abs) } }
    .reject { |delta| apply(position, delta).any?(&:negative?) }
    .reject { |(dx, dy)| dx.abs > map.values.first.length || dy.abs > map.length }
    .reject { |delta| empty?(map, apply(position, delta)) }

  _acc_arround(map, position, new_deltas, occ.concat(more_occ.map { |delta| apply(position, delta) }))
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

      if occ?(map, [x, y]) && occ_around(map, [x, y]) >= 5
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
