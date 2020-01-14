module Displayable
  def press_enter
    puts "\n\n\n"
    puts 'Press Enter to continue...'
    gets
  end

  def clear_and_pad_screen
    (system 'clear') || (system 'cls')
    puts "\n"
  end

  def user_input(prompt, error_message, answer = nil)
    clear_and_pad_screen

    loop do
      puts prompt
      answer = gets.chomp
      break if yield(answer)
      puts error_message
    end

    answer
  end

  def new_display(message = nil)
    clear_and_pad_screen
    puts message if message
    puts self unless message
    press_enter
  end
end

class Move
  def >(other_move)
    wins?(other_move)
  end

  def <(other_move)
    other_move > self
  end
end

class Rock < Move
  def wins?(other_move)
    other_move.is_a?(Scissors) || other_move.is_a?(Lizard)
  end

  def to_s
    'rock'
  end
end

class Paper < Move
  def wins?(other_move)
    other_move.is_a?(Rock) || other_move.is_a?(Spock)
  end

  def to_s
    'paper'
  end
end

class Scissors < Move
  def wins?(other_move)
    other_move.is_a?(Paper) || other_move.is_a?(Lizard)
  end

  def to_s
    'scissors'
  end
end

class Lizard < Move
  def wins?(other_move)
    other_move.is_a?(Paper) || other_move.is_a?(Spock)
  end

  def to_s
    'lizard'
  end
end

class Spock < Move
  def wins?(other_move)
    other_move.is_a?(Rock) || other_move.is_a?(Scissors)
  end

  def to_s
    'spock'
  end
end

class Player
  attr_reader :name, :move, :score

  MOVES = {
    'r'  => Rock.new,
    'p'  => Paper.new,
    'sc' => Scissors.new,
    'l'  => Lizard.new,
    'sp' => Spock.new
  }

  def initialize
    @score = 0
    set_name
  end

  def reset_score
    self.score = 0
  end

  def increment_score
    self.score += 1
  end

  private

  attr_writer :name, :move, :score
end

class Human < Player
  include Displayable

  def set_name
    prompt = "What's your name?"
    err_msg = "Sorry, must enter a value."
    self.name = user_input(prompt, err_msg, '') { |input| !input.empty? }
  end

  def choose
    options = MOVES.keys
    options = "#{options.slice(0..-2).join(', ')}, or #{options.last}"
    names = MOVES.values
    names = "#{names.slice(0..-2).join(', ')}, or #{names.last}"

    prompt = "Please choose #{names} (#{options}):"
    err_msg = "Sorry, must be #{options}."

    choice = user_input(prompt, err_msg) { |input| MOVES.keys.include?(input) }

    self.move = MOVES[choice]
  end
end

class R2D2 < Player
  def set_name
    self.name = 'R2D2'
  end

  def choose
    # Always chooses rock
    self.move = MOVES.values[0]
  end
end

class Hal < Player
  def set_name
    self.name = 'Hal'
  end

  def choose
    # High tendency to choose scissors
    # Rarely chooses rock
    # Never chooses paper
    hal_index = [0, 2, 2, 2, 2, 2, 3, 3, 4, 4].sample
    self.move = MOVES.values[hal_index]
  end
end

class Chappie < Player
  def set_name
    self.name = 'Chappie'
  end

  def choose
    # Only chooses rock, paper, or scissors
    self.move = MOVES.values[0..2].sample
  end
end

class Sonny < Player
  def set_name
    self.name = 'Sonny'
  end

  def choose
    # Only chooses lizard or spock
    self.move = MOVES.values[3..-1].sample
  end
end

class Number5 < Player
  def set_name
    self.name = 'Number 5'
  end

  def choose
    # Chooses rock, paper, scissors, lizard, or spock
    # All choices are equally likely
    self.move = MOVES.values.sample
  end
end

class Round
  include Displayable
  @@round_counter = 0

  def initialize(human, computer)
    @human = human
    @computer = computer

    @@round_counter += 1
    @round_number = @@round_counter
  end

  def self.reset_round_counter
    @@round_counter = 0
  end

  def play
    human.choose
    computer.choose

    self.human_choice = human.move
    self.computer_choice = computer.move

    self.winner = determine_winner
    winner&.increment_score

    self.human_score = human.score
    self.computer_score = computer.score
  end

  def determine_winner
    return human if human.move > computer.move
    return computer if human.move < computer.move
    nil
  end

  def to_s
    outcome_str = winner ? "#{winner.name} won the round.\n" : "It's a tie.\n"

    human_name = human.name
    computer_name = computer.name

    "Round #{round_number}:\n" \
    "  #{human_name} chose #{human_choice}.\n" \
    "  #{computer_name} chose #{computer_choice}.\n" \
    "  #{outcome_str}" \
    "  #{human_name}'s score: #{human_score}.\n" \
    "  #{computer_name}'s score: #{computer_score}.\n"
  end

  private

  attr_accessor :human_choice, :computer_choice, :human_score, :computer_score,
                :winner
  attr_reader   :human, :computer, :round_number
end

class Match
  include Displayable
  attr_reader :rounds, :winner

  MATCH_WIN_SCORE = 10
  @@match_counter = 0

  def initialize(human, computer)
    @human    = human
    @computer = computer

    @rounds   = []
    Round.reset_round_counter

    @@match_counter += 1
    @match_number = @@match_counter
  end

  def add(round)
    rounds << round
  end

  def match_over?
    human.score == MATCH_WIN_SCORE || computer.score == MATCH_WIN_SCORE
  end

  def play
    loop do
      self.current_round = Round.new(human, computer)
      current_round.play
      current_round.new_display
      add(current_round)
      break if match_over?
    end

    human_won = human.score == MATCH_WIN_SCORE
    self.winner = human_won ? human : computer
  end

  def to_s
    "##########\n" \
    "Match #{match_number}\n" \
    "##########\n" \
    "\n" \
    "There were #{rounds.size} rounds in this match."
  end

  private

  attr_accessor :human, :computer, :current_round
  attr_writer   :rounds, :winner
  attr_reader   :match_number
end

class RPSGame
  include Displayable

  RANDOM = '?'

  OPPONENTS = {
    'r' => R2D2,
    'h' => Hal,
    'c' => Chappie,
    's' => Sonny,
    'n' => Number5
  }

  def initialize
    @human = Human.new

    computer = choose_opponent
    @computer = computer.new

    @matches_played = []
  end

  def choose_opponent
    options = [RANDOM] + OPPONENTS.keys
    options_str = "#{options.slice(0..-2).join(', ')}, or #{options.last}"

    directions = OPPONENTS.map do |letter, class_name|
      "#{letter} for #{class_name}"
    end

    prompt = ["Choose your opponent. Each one has a different behavior. Enter:",
              "#{RANDOM} for a random opponent"] + directions
    err_msg = "Sorry, must be #{RANDOM}, #{options_str}."

    answer = user_input(prompt, err_msg) do |input|
      options.include?(input)
    end

    if answer == RANDOM then OPPONENTS.values.sample
    else                     OPPONENTS[answer]
    end
  end

  def display_welcome_message
    clear_and_pad_screen
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock!"
    press_enter
  end

  def display_goodbye_message
    clear_and_pad_screen
    puts "Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Good bye!"
  end

  def display_history
    loop do
      number_of_matches = matches_played.size
      suffix = number_of_matches > 1 ? 'es' : ''

      prompt = [
        "You have played #{number_of_matches} match#{suffix} so far.",
        "Enter a number from 1 to #{number_of_matches} to review that match.",
        "Which match would you like to review? Enter q to stop reviewing."
      ]

      err_msg = "Sorry, must be a number from 1 to #{number_of_matches}."

      answer = user_input(prompt, err_msg) do |input|
        input == 'q' || (1..number_of_matches).cover?(input.to_i)
      end

      break if answer == 'q'

      display_match_history(answer.to_i)
    end
  end

  def display_match_history(match_number)
    match = matches_played[match_number - 1]
    match.new_display
    match.rounds.each(&:new_display)
    winner_name = match.winner.name
    new_display("The winner of Match #{match_number} was #{winner_name}.")
  end

  def play_again?
    prompt = "Would you like to play another match? (y/n)"
    err_msg = "Sorry, must be y or n."

    answer = user_input(prompt, err_msg) do |input|
      ['y', 'n'].include? input.downcase
    end

    return false if answer.downcase == 'n'
    return true if answer.downcase == 'y'
  end

  def review_matches?
    prompt = "Would you like to review past matches? (y/n)"
    err_msg = "Sorry, must be y or n."

    answer = user_input(prompt, err_msg) do |input|
      ['y', 'n'].include? input.downcase
    end

    return false if answer.downcase == 'n'
    return true if answer.downcase == 'y'
  end

  def reset_score
    human.reset_score
    computer.reset_score
  end

  def game_loop
    loop do
      self.current_match = Match.new(human, computer)
      current_match.play
      new_display("#{current_match.winner.name} won the match!")
      matches_played << current_match

      display_history if review_matches?
      break unless play_again?
      reset_score
    end
  end

  def play
    display_welcome_message
    game_loop
    display_goodbye_message
  end

  private

  attr_accessor :human, :computer, :current_match, :matches_played
end

RPSGame.new.play
