def read(file)
  File.open(file).each_line.take(2).last.strip
end

def parse(buses)
  buses
    .split(",")
    .each_with_index
    .reject { |(b,_idx)| b == "x" }
    .map { |b, idx| [b.to_i, idx] }
end

def find_match(buses)
  buses.reduce([0, 1]) do |(ts, step), (bus, delay)|
    ts = (ts..).step(step).find { |time| (time+delay) % bus == 0 }
    [ts, step * bus]
  end.first
end

puts find_match(parse(read('input.sample.txt'))) == 1068781
puts find_match(parse("17,x,13,19")) == 3417
puts find_match(parse("67,7,59,61")) == 754018
puts find_match(parse("67,x,7,59,61")) == 779210
puts find_match(parse("67,7,x,59,61")) == 1261476
puts find_match(parse("1789,37,47,1889")) == 1202161486

puts find_match(parse(read('input.txt')))
