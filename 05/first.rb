require './lib'

puts File.read("input.txt").each_line.map { |line| seat_id(line.strip) }.max

