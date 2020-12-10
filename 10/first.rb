def adapters(file)
  File.open(file, 'r').each_line.map { |line| line.strip.to_i }
end

sorted = adapters('input.sample.txt').sort
sorted = adapters('input.sample2.txt').sort
sorted = adapters('input.txt').sort

left = sorted.dup
right = sorted.dup

last = left.pop
right.shift

jump_map = left.zip(right).each_with_object(Hash.new { |_key| 1 }) do |(a, b), map|
  map[b-a] += 1
end


puts jump_map.inspect
puts jump_map[3] * jump_map[1]
puts last+3

