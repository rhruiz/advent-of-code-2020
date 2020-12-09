def parse(file)
  File.open(file, 'r').each_line.map { |line| line.strip.to_i }.to_a
end

def find_first_match(numbers, start_at, range)
  target = numbers[start_at+range]

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

def find_sum_of(numbers, target)
  length = numbers.length

  numbers
    .each_with_index
    .lazy
    .map do |_n, index|
      (index...numbers.length).map { |candidate| numbers[index..candidate] }
    end
    .find do |ranges|
      ranges.find(->{[]}) do |numbers|
        sum = numbers.reduce(0, &:+)
        sum >= target
      end.reduce(0, &:+) == target
    end
    .find do |numbers|
      numbers.reduce(0, &:+) == target
    end
end

# target = find_broken(parse('input.txt'), 25)

numbers = parse('input.sample.txt')
range = 5

numbers = parse('input.txt')
range = 25

target = find_broken(numbers, range)
puts target

the_sum = find_sum_of(numbers, target)
puts the_sum.inspect

puts the_sum.min + the_sum.max

