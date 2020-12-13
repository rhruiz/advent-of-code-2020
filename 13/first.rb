def parse(file)
  (timestamp, buses) = File.open(file).each_line.to_a
  buses = buses.split(",").reject { |b| b == "x" }.map(&:to_i)

  [timestamp.strip.to_i, buses]
end

(timestamp, buses) = parse('input.txt')
next_buses = buses.map { |bus| [bus, bus - timestamp%bus] }
le_bus = next_buses.min_by(&:last)

puts le_bus.inspect
puts le_bus.reduce(&:*)
