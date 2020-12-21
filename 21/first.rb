require 'set'

def parse(input)
  File.open(input, 'r').each_line.map do |line|
    (ingredients, allergens) = line.strip.split('(contains ')

    ingredients = ingredients.split(' ')
    allergens = allergens.chomp(')').split(', ')

    [Set.new(ingredients), Set.new(allergens)]
  end
end

foods = parse('input.txt')

sus = foods.each_with_object({}) do |(ingredients, allergens), map|
  ingredients.each do |i|
    allergens.each do |a|
      found_in_other_ingredients = foods.any? do |(ingredients, allergens)|
        allergens.member?(a) && !ingredients.member?(i)
      end

      map[i] ||= Set.new
      map[i] << a unless found_in_other_ingredients
    end
  end
end

safes = Set.new(sus.keep_if { |k, v| v.empty? }.keys)

puts foods.reduce(0) { |acc, (ingredients, _allergens)| acc + ingredients.intersection(safes).count }
