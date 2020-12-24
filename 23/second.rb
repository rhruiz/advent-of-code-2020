def debug(&msg)
  return
  puts msg.call
end

def game(cups, last, max)
  c1 = cups[cups[0]]
  c2 = cups[c1]
  c3 = cups[c2]

  cups[cups[0]] = cups[c3]

  destination = cups[0] - 1

  loop do
    break unless [c1, c2, c3].member?(destination)
    destination -= 1
  end

  if destination < 1
    destination = max

    loop do
      break unless [c1, c2, c3].member?(destination)
      destination -= 1
    end
  end

  cups[c3] = cups[destination]
  cups[destination] = c1

  last = c3 if cups[c3] == 0

  first = cups[cups[0]]

  cups[last] = cups[0]
  last = cups[0]
  cups[last] = 0
  cups[0] = first

  [cups, last]
end

cups = "463528179".chars.map(&:to_i) # input
# cups = "389125467".chars.map(&:to_i) # sample

labels = Hash.new { |h, k| h[k] = k + 1 }

cups.each_with_index do |cup, idx|
  next if idx == labels.length - 2
  labels[cup] = cups[idx+1]
end

rounds = 10_000_000
length = 1_000_000

labels[cups.last] = 0
labels[cups.last] = 10
labels[1_000_000] = 0
labels[0] = cups.first

(cups, _last) = (1..rounds).reduce([labels, length]) do |(cups, last), round|
  puts "round #{round}" if round % 100_000 == 0
  game(cups, last, length)
end

num = cups[1]
puts cups[num] * num

