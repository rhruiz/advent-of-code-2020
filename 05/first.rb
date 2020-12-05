require './lib'

puts File.read("input.txt").each_line.map { |line| seat_id(line.strip) }.max

class FirstTest < Minitest::Test
  def test_answer
    assert 866 == File.read("input.txt").each_line.map { |line| seat_id(line.strip) }.max
  end
end

