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
end.delete_if { |_k, v| v.empty? }

def solve(sus, certains)
  return certains if sus.empty?

  ruled_out = certains.values.reduce(Set.new, :merge)
  sus.transform_values! { |v| v.difference(ruled_out) }
  (new_certains, sus) = sus.partition { |_k, v| v.size == 1 }.map(&:to_h)

  return certains.merge(sus) if new_certains.empty?

  solve(sus, certains.merge(new_certains))
end

puts solve(sus, {}).sort_by { |(k, v)| v.first }.map(&:first).join(",")
