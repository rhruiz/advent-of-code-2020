require 'set'

def parse(file)
  decks = File.read(file).split("\n\n")

  decks.map { |deck| deck.split("\n").drop(1).map { |l| l.strip.to_i } }
end

def game(decks)
  previous = Set.new
  rounds = 0

  loop do
    return [0, decks] if previous.member?(decks)
    previous.add(decks.map(&:dup))

    if decks.any?(&:empty?)
      return [decks.find_index(&:any?), decks]
    end

    draw = decks.map(&:shift)

    winner =
      if decks[0].length >= draw[0] && decks[1].length >= draw[1]
        game([decks[0].take(draw[0]), decks[1].take(draw[1])]).first
      else
        draw[0] > draw[1] ? 0 : 1
      end

    decks[winner].push(draw[winner])
    decks[winner].push(draw[(winner+1)%2])
  end
end

def score(decks)
  decks.map do |deck|
    deck.reverse.each_with_index.reduce(0) do |score, (card, index)|
      score + card * (index + 1)
    end
  end
end

(winner, decks) = game(parse('input.txt'))

puts "#{winner+1} wins"
puts score(decks)

