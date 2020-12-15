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

def addresses(mask, address)
  address = mask.chars.each_with_index.reduce(address) do |address, (chr, index)|
    address = apply_mask(35 - index, 1, address) if chr == "1"
    address
  end

  find_x = ->(chr) { chr == "X" }

  xs = mask.chars.count(&find_x)

  x_map = mask.chars.each_with_index.map do |chr, index|
    if find_x[chr]
      35 - index
    else
      nil
    end
  end.compact.reverse

  queue = []

  (0...2**xs).each do |mask|
    new_addr = x_map.each_with_index.reduce(address) do |address, (target_index, mask_index)|
      apply_mask(target_index, (mask >> mask_index) & 1, address)
    end

    queue.push(new_addr)
  end

  queue
end

def apply_mask(position, bit, value)
  mask = 1 << position
  (value & ~mask) | ((bit << position) & mask)
end

memory = parse('input.txt').reduce([[], {}]) do |(mask, memory), instruction|
  case instruction.first
  when :mask
    [instruction.last, memory]
  when :mem
    (_, position, value) = instruction

    addresses(mask, position).each do |position|
      memory[position] = value
    end

    [mask, memory]
  else
    raise "cpu panic"
  end
end.last

puts memory.values.reduce(&:+) # 3801988250775
