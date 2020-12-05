require 'minitest/test'

def seat_id(pass)
  # BFFFBBFRRR
  row = pass.chars.take(7).map { |chr| chr == "F" ? 0 : 1 }
  col = pass.chars.drop(7).map { |chr| chr == "L" ? 0 : 1 }

  row.join.to_i(2) * 8 + col.join.to_i(2)
end

class Test < Minitest::Test
  def test_seat_id_example
    assert seat_id("BFFFBBFRRR") == 567
    assert seat_id("FFFBBBFRRR") == 119
    assert seat_id("BBFFBBFRLL") == 820
  end
end
