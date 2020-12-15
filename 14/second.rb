def parse(file)
  File.open(file, 'r').each_line.lazy.map do |line|
    line = line.strip
    if line.start_with?("mask =")
      [:mask, line.split(" = ").last]
    elsif line.start_with?("mem[")
      line.scan(/mem\[(\d+)\] = (\d+)/)

      [:mem, $1.to_i, $2.to_i]
    else
      raise "boom"
    end
  end
end

class Mask
  attr_reader :x_map

  def find_x(chr)
    chr == "X"
  end

  def initialize(str)
    @xs = str.chars.count(&method(:find_x))

    @x_map = str.chars.each_with_index.map do |chr, index|
      if find_x(chr)
        35 - index
      else
        nil
      end
    end.compact.reverse

    @fixed_mask = str.chars.reduce(0) do |address, chr|
      bit = case chr
            when "0" then 0
            when "1" then 1
            when "X" then 0
            end
      address << 1 | bit
    end
  end

  def floating
    (0...2**@xs)
  end

  def addresses(base_address)
    address = base_address | @fixed_mask

    floating.lazy.map do |bitmap|
      @x_map.each_with_index.reduce(address) do |address, (target_index, mask_index)|
        set_bit(address, target_index, (bitmap >> mask_index) & 1)
      end
    end
  end

  def set_bit(target, position, bit)
    mask = 1 << position
    (target & ~mask) | ((bit << position) & mask)
  end
end

memory = parse('input.txt').reduce([[], {}]) do |(mask, memory), instruction|
  case instruction.first
  when :mask
    [Mask.new(instruction.last), memory]
  when :mem
    (_, position, value) = instruction

    mask.addresses(position).each do |position|
      memory[position] = value
    end

    [mask, memory]
  else
    raise "cpu panic"
  end
end.last

puts memory.values.reduce(&:+) # 3801988250775
