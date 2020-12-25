def do_loop(subject, value, times = 1)
  (1..times).reduce(value) do |value, _i|
    (value * subject) % 20201227
  end
end

def loop_size(subject, value, target)
  loop_size = 0

  loop do
    loop_size += 1
    value = do_loop(subject, value)
    break if value == target
  end

  loop_size
end

# input
(cpuk, dpuk) = File.read("input.txt").each_line.map(&:strip).map(&:to_i)

# sample
# (cpuk, dpuk) = [5764801, 17807724]

subject = 7
value = 1

loop_size = loop_size(subject, value, cpuk)

# raise "CryptoError" if cpuk != do_loop(7, 1, loop_size)

encryption_key = do_loop(dpuk, 1, loop_size)

puts encryption_key
