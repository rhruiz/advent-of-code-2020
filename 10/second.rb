def adapters(file)
  File.open(file, 'r').each_line.map { |line| line.strip.to_i }
end

sorted = adapters('input.sample.txt').sort
sorted = adapters('input.sample2.txt').sort
sorted = adapters('input.txt').sort

solution = Hash.new { |_k| 0 }
solution[0] = 1

sorted.each_with_object(solution) do |adapter, solution|
  solution[adapter] += solution[adapter - 1]
  solution[adapter] += solution[adapter - 2]
  solution[adapter] += solution[adapter - 3]
end

puts solution[sorted.last]

