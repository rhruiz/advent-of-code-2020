require './lib'

def bag_count(bag_map, qty, bag)
  bag_map[bag].reduce(qty) do |acc, (sub_qty, sub_bag)|
    acc + qty * (bag_count(bag_map, sub_qty, sub_bag))
  end
end

bag_map = Hash[*parse_bags('input.txt')]
puts bag_count(bag_map, 1, "shiny gold") - 1
