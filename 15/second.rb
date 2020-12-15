numbers = [0, 3, 6]
numbers = [1, 3, 2]
numbers = [2, 1, 3]
numbers = [3, 1, 2]
numbers = [7, 14, 0, 17, 11, 1, 2]

def compute(numbers)
  last_number = numbers.last
  initial = numbers.length

  numbers = numbers.each_with_index.each_with_object({}) do |(n, idx), acc|
    acc[n] = [idx]
  end

  (initial..).lazy.map do |turn|
    puts turn if turn % 1_000_000 == 0
    numbers[last_number] ||= []

    new_number =
      if numbers[last_number].length > 1
        numbers[last_number].take(2).reduce(&:-)
      else
        0
      end

    numbers[last_number] = numbers[last_number].take(2)

    numbers[new_number] ||= []
    numbers[new_number].unshift(turn)

    last_number = new_number
  end.drop(30000000-1-initial).first
end

puts compute(numbers).inspect
