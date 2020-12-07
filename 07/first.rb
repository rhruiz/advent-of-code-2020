require 'set'

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

def can_carry(bag_map, queue, acc)
  desired_bag = queue.shift
  containers = bag_map
    .select { |bag, can_carry| can_carry.any? { |(qty, bag)| bag == desired_bag } }
    .reject { |bag, _can_carry| acc.member?(bag) }

  return acc if desired_bag.nil?

  case containers
    when []
      acc
    else
      can_carry(bag_map, queue.concat(containers.keys), acc.merge(containers.keys))
    end
end

bag_map = Hash[*parse_bags('input.txt')]
puts can_carry(bag_map, ["shiny gold"], Set.new).length
