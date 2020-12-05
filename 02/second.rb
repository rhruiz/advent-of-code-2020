puts(File.open("input.txt").each_line.select do |line|
  (first, second, letter, password) = line.scan(/^(\d+)\-(\d+) (\w): (\w+)$/).first
  first = first.to_i - 1
  second = second.to_i - 1

  (password.chars[first] == letter) ^ (password.chars[second] == letter)
end.size)
