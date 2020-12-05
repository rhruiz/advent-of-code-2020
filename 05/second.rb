require './lib'
require 'set'

seats = File.read("input.txt").each_line.map { |line| seat_id(line.strip) }
cache = Set.new(seats)

first_id = 0b0000001000
last_id =  0b1111111000

puts (first_id...last_id).select { |id| !cache.member?(id) && cache.member?(id+1) && cache.member?(id-1) }
