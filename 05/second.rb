require './lib'
require 'set'

class SecondTest < Minitest::Test
  def test_answer
    seats = File.read("input.txt").each_line.map { |line| seat_id(line.strip) }
    cache = Set.new(seats)

    first_id = 0b0000001000
    last_id =  0b1111111000

    assert_equal 583, (first_id...last_id).find { |id| !cache.member?(id) && cache.member?(id+1) && cache.member?(id-1) }
  end

  def test_alternative
    seats = File.read("input.txt").each_line.map { |line| seat_id(line.strip) }

    assert_equal 583, seats
      .sort!
      .each_with_index
      .find { |(id, index)| seats[index + 1] == id + 2 }
      .first
      .yield_self { |id| id + 1 }
  end
end
