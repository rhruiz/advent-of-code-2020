def parse(file)
  File.open(file, 'r').each_line.map { |line| line.strip.to_i }.to_a
end

def find_first_match(numbers, start_at, range)
  target = numbers[start_at+range]

  puts "finding #{target}"

  numbers
    .drop(start_at)
    .take(range)
    .combination(2)
    .find { |(n, m)| n != m && n + m == target }
end

def find_broken(numbers, range)
  index = (0..(numbers.length-range)).find do |n|
    find_first_match(numbers, n, range) == nil
  end

  numbers[index+range]
end

puts find_broken(parse('input.sample.txt'), 5)

puts find_broken(parse('input.txt'), 25) # 556543474

