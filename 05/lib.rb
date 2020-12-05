require 'minitest/test'

def seat_id(pass)
  pass.chars.reduce(0) { |num, chr| (num << 1) + (%w[F L].member?(chr) ? 0 : 1) }
end

class Test < Minitest::Test
  def test_seat_id_example
    assert seat_id("BFFFBBFRRR") == 567
    assert seat_id("FFFBBBFRRR") == 119
    assert seat_id("BBFFBBFRLL") == 820
  end
end
