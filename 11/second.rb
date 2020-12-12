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

def at(map, (x,y))
  (map[y] || [])[x]
end

def occ?(map, position)
  at(map, position) == "#"
end

def floor?(map, (x, y))
  at(map, position) == "."
end

def empty?(map, position)
  ["L", nil].member?(at(map, position))
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

def render(map)
  map.values.each { |line| puts line.values.join("") }
  puts ""
  puts "*" * map.first.length
  puts ""
end

map = parse('input.sample.txt')
map = parse('input.txt')

rounds = 0

loop do
  render(map)
  rounds = rounds + 1
  new_map = {}

  map.keys.each do |y|
    new_map[y] = {}

    map[y].keys.each do |x|
      new_map[y][x] = map[y][x]

      next if new_map[y][x] == "."

      if empty?(map, [x, y]) && occ_around(map, [x, y]) == 0
        new_map[y][x] = "#"
      end

      if occ?(map, [x, y]) && occ_around(map, [x, y]) >= 5
        new_map[y][x] = "L"
      end
    end
  end

  break if new_map == map

  map = new_map
end

puts rounds

puts map.values.flatten.map(&:values).flatten.select { |value| value == "#" }.count
