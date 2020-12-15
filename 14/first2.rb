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
  def initialize(str)
    len = str.length - 1

    @bitmasks = str.chars.each_with_index.map do |chr, index|
      case chr
      when "0"
        [:'&', ~(1 << (len - index))]
      when "1"
        [:'|', 1 << (len-index)]
      else
        nil
      end
    end.compact
  end

  def apply(value)
    @bitmasks.reduce(value) do |value, (op, mask)|
      value.send(op, mask)
    end
  end
end

memory = parse('input.txt').reduce([[], {}]) do |(mask, memory), instruction|
  case instruction.first
  when :mask
    [Mask.new(instruction.last), memory]
  when :mem
    (_, position, value) = instruction
    memory[position] = mask.apply(value)

    [mask, memory]
  else
    raise "cpu panic"
  end
end.last

puts memory.values.reduce(&:+) # 5902420735773
