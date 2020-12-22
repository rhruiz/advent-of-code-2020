def parse(file)
  decks = File.read(file).split("\n\n")

  decks.map { |deck| deck.split("\n").drop(1).map { |l| l.strip.to_i } }
end

decks = parse('input.txt')

loop do
  break if decks.any?(&:empty?)

  draw = decks.map(&:shift)

  if draw[0] > draw[1]
    decks[0].push(draw[0])
    decks[0].push(draw[1])
  else
    decks[1].push(draw[1])
    decks[1].push(draw[0])
  end
end

puts decks.map { |deck| deck.reverse.each_with_index.reduce(0)  { |score, (card, index)| score + card*(index+1) } }
