def parse_bags(input)
  File.open(input, 'r').each_line.flat_map do |line|
    ((bag_name, contents)) = line.scan(/^(\w+ \w+) bags contain(.*)$/)

    [bag_name, bag_contents(contents, [])]
  end
end

def bag_contents(input, acc)
  case input
  when ""
    acc
  when / no other bags./
    []
  when / (\d+) (\w+ \w+) bags?[,.](.*)/
    bag_contents($3, acc.append([$1.to_i, $2]))
  end
end

