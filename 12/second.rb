def parse(file)
  File.open(file, 'r').each_line.map do |line|
    (direction, amount) = line.downcase.strip.split("", 2)

    [direction.to_sym, amount.to_i]
  end
end

class Boat
  attr_accessor :position, :waypoint

  def initialize
    self.position = (0+0i)
    self.waypoint = (10+1i)
  end

  def move((_, amount))
    self.position += self.waypoint * amount
  end

  def move_waypoint((direction, amount))
    self.waypoint += Complex.polar(amount, [:e, :n, :w, :s].index(direction) * Math::PI/2)
  end

  def rotate((direction, amount))
    self.waypoint *= Complex.polar(1, (direction == :l ? 1 : -1)*Math::PI/180*amount)
  end

  def [](transformation)
    method({r: :rotate, l: :rotate, f: :move}.fetch(transformation.first, :move_waypoint))
      .call(transformation)
  end

  def distance
    position.rectangular.map(&:abs).reduce(&:+).round
  end
end

puts(parse('input.txt')
  .each_with_object(Boat.new) { |transformation, boat| boat[transformation] }
  .distance)
