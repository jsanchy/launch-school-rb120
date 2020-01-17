class Card
  FACE_CARDS = %w(J Q K)

  attr_reader :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{rank} of #{suit}"
  end

  def ace?
    rank == 'A'
  end

  def face_card?
    FACE_CARDS.include?(rank)
  end

  def value
    if ace?
      11
    elsif face_card?
      10
    else
      rank.to_i
    end
  end
end

class Deck
  RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  SUITS = %w(Clubs Diamonds Hearts Spades)

  attr_reader :cards

  def initialize
    @cards = create_deck
  end

  def create_deck
    RANKS.product(SUITS).map { |card| Card.new(*card) }.shuffle
  end

  def deal
    cards.pop
  end
end

module Hand
  attr_accessor :cards

  def show_hand
    puts "---- #{name}'s Hand ----"
    cards.each do |card|
      puts "=> #{card}"
    end
    puts "=> Total: #{total}"
    puts ""
  end

  def total
    total = cards.reduce(0) { |sum, card| sum + card.value }

    # correct for Aces
    cards.select(&:ace?).count.times do
      break if total <= 21
      total -= 10
    end

    total
  end

  def hit(new_card)
    cards << new_card
  end

  def busted?
    total > 21
  end
end

class Participant
  include Hand

  attr_accessor :name, :cards

  def initialize
    @cards = []
    set_name
  end
end

class Player < Participant
  ALPHABET = ('a'..'z').to_a.join

  def set_name
    name = nil
    loop do
      puts "What's your name?"
      name = gets.chomp
      break if name.downcase.count(ALPHABET) > 0
      puts "Sorry, must enter at least one letter."
    end
    self.name = name
  end

  def show_flop
    show_hand
  end
end

class Dealer < Participant
  ROBOTS = ['R2D2', 'Hal', 'Chappie', 'Sonny', 'Number 5']

  def set_name
    self.name = ROBOTS.sample
  end

  def show_flop
    puts "---- #{name}'s Hand ----"
    puts cards.first
    puts " ?? "
    puts ""
  end
end

class TwentyOne
  attr_accessor :deck, :player, :dealer

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def reset
    self.deck = Deck.new
    player.cards = []
    dealer.cards = []
  end

  def deal_cards
    2.times do
      player.hit(deck.deal)
      dealer.hit(deck.deal)
    end
  end

  def show_flop
    player.show_flop
    dealer.show_flop
  end

  def player_turn
    player_name = player.name
    puts "#{player_name}'s turn..."

    loop do
      puts "Would you like to (h)it or (s)tay?"

      if hit_or_stay == 's'
        puts "#{player_name} stayed!"
        break
      end

      player.hit(deck.deal)
      puts "#{player_name} hits!"
      player.show_hand
      break if player.busted?
    end
  end

  def hit_or_stay
    answer = nil
    loop do
      answer = gets.chomp.downcase
      break if %(h s).include?(answer)
      puts "Sorry, must enter 'h' or 's'."
    end
    answer
  end

  def dealer_turn
    puts "#{dealer.name}'s turn..."

    loop do
      break if dealer.total >= 17
      puts "Dealer hits!"
      dealer.hit(deck.deal)
    end

    if dealer.busted?
      puts "Dealer busted!"
    else
      puts "Dealer stays!"
    end
  end

  def show_busted
    if player.busted?
      puts "It looks like #{player.name} busted! #{dealer.name} wins!"
    elsif dealer.busted?
      puts "It looks like #{dealer.name} busted! #{player.name} wins!"
    end
  end

  def show_cards
    player.show_hand
    dealer.show_hand
  end

  def show_result
    if player.total > dealer.total
      puts "It looks like #{player.name} wins!"
    elsif player.total < dealer.total
      puts "It looks like #{dealer.name} wins!"
    else
      puts "It's a tie!"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      puts "Sorry, must be y or n."
    end

    answer == 'y'
  end

  def start
    loop do
      system 'clear'
      deal_cards
      show_flop

      player_turn
      if player.busted?
        show_busted
        if play_again?
          reset
          next
        else
          break
        end
      end

      dealer_turn
      if dealer.busted?
        show_busted
        if play_again?
          reset
          next
        else
          break
        end
      end

      # both stayed
      show_cards
      show_result
      play_again? ? reset : break
    end

    puts "Thank you for playing Twenty-One. Goodbye!"
  end
end

game = TwentyOne.new
game.start
