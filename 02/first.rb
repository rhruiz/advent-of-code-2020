def frequency(enumerable)
  enumerable.group_by { |me| me }.transform_values(&:size)
end

puts(File.open("input.txt").lines.select do |line|
  (min, max, letter, password) = line.scan(/^(\d+)\-(\d+) (\w): (\w+)$/).first
  min = min.to_i
  max = max.to_i

  (min..max).member?(frequency(password.chars)[letter] || 0)
end.size)
