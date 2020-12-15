numbers = [0, 3, 6]
numbers = [1, 3, 2]
numbers = [2, 1, 3]
numbers = [3, 1, 2]
numbers = [7, 14, 0, 17, 11, 1, 2]

def compute(numbers)
  last_number = numbers.last

  numbers = numbers.each_with_index.each_with_object(Hash.new) do |(n, idx), acc|
    acc[n] = [idx]
  end

  initial = numbers.length

  (initial..).lazy.map do |turn|
    numbers[last_number] ||= []

    if numbers[last_number].length > 1
      new_number = numbers[last_number].take(2).reduce(&:-)

      numbers[new_number] ||= []
      numbers[new_number].unshift(turn)
    else
      numbers[0] ||= []
      numbers[0].unshift(turn)

      new_number = 0
    end

    last_number = new_number
  end.drop(2019-initial).take(1).to_a.first
end

puts compute(numbers).inspect
