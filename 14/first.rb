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

def mask(mask)
  # returns [mask, position, value]
  mask
    .chars.each_with_index.map do |chr, index|
      case chr
      when "0"
        [1 << 35 - index, 35 - index, 0]
      when "1"
        [1 << 35 - index, 35 - index, 1]
      when "X"
        nil
      end
    end
    .compact
end

def apply_mask(mask, value)
  mask.reduce(value) do |value, (mask, position, bit)|
    (value & ~mask) | ((bit << position) & mask)
  end
end

memory = parse('input.txt').reduce([[], {}]) do |(mask, memory), instruction|
  case instruction.first
  when :mask
    mask = mask(instruction.last)

    [mask, memory]
  when :mem
    (_, position, value) = instruction
    memory[position] = apply_mask(mask, value)

    [mask, memory]
  else
    raise "cpu panic"
  end
end.last

puts memory.values.reduce(&:+)
