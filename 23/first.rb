def debug(msg)
  puts msg
end

def game(cups)
  current = cups.shift

  debug cups.inspect
  debug "current: #{current}"

  picked = cups.shift(3)
  debug "picked: #{picked.inspect}"

  target = current - 1
  found = nil

  cups.unshift(current)

  loop do
    index = cups.find_index { |cup| cup == target }

    if index
      found = index
      break
    else
      target -= 1
      target = cups.max if target < cups.min
    end
  end

  debug "destination: #{cups[found]}"

  cups = cups.take(found+1).concat(picked).concat(cups.drop(found+1))
  cups.push(cups.shift)
end

cups = "463528179".chars.map(&:to_i) # input
# cups = "389125467".chars.map(&:to_i) # sample

final = (1..100).reduce(cups) do |cups, round|
  debug "\n-- move #{round} --"
  game(cups)
end

one_index = final.find_index { |n| n == 1 }

puts final.drop(one_index+1).take(final.length).concat(final.take(one_index)).join("")
