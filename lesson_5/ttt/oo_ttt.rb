class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]]              # diagonals

  def initialize
    @squares = {}
    reset
  end

  def [](key)
    @squares[key]
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      return squares.first.marker if three_identical_markers?(squares)
    end

    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize

  def find_at_risk_keys(marker)
    at_risk_keys = []
    WINNING_LINES.each do |line|
      square_key = search_line(line, marker)
      at_risk_keys << square_key if square_key
    end
    at_risk_keys
  end

  def search_line(line, marker)
    squares = @squares.values_at(*line)
    return unless this_many?(squares, marker, 2)
    line.find { |key| @squares[key].unmarked? }
  end

  def find_double_threat_keys(marker)
    keys = find_lines_with_one(marker).flatten
    unmarked_keys_at_intersections(keys)
  end

  def find_lines_with_one(marker)
    WINNING_LINES.select do |line|
      squares = @squares.values_at(*line)
      this_many?(squares, marker, 1)
    end
  end

  def unmarked_keys_at_intersections(keys)
    keys = keys.select { |key| @squares[key].unmarked? }

    square_count_hsh = keys.uniq.each_with_object({}) do |key, hsh|
      hsh[key] = keys.count(key)
    end

    square_count_hsh.select { |_, count| count > 1 }.keys
  end

  private

  def this_many?(squares, marker, marker_count)
    squares.count { |square| square.marker == marker } == marker_count &&
      squares.count(&:unmarked?) == 3 - marker_count
  end

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.min == markers.max
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end
end

class Player
  attr_reader :marker, :score, :name

  def initialize(marker)
    @marker = marker
    reset_score
  end

  def set_name(name)
    @name = name
  end

  def set_marker(marker)
    @marker = marker
  end

  def reset_score
    @score = 0
  end

  def increment_score
    @score += 1
  end
end

class TTTGame
  HUMAN_MARKER = "X"
  COMPUTER_MARKER = "O"
  FIRST_TO_MOVE = HUMAN_MARKER
  SCORE_TO_WIN = 5

  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    @current_marker = FIRST_TO_MOVE
  end

  def play
    clear
    display_welcome_message

    pick_names

    pick_marker

    match_loop

    display_final_result
    display_goodbye_message
  end

  private

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def pick_names
    pick_human_name
    pick_computer_name
  end

  def pick_human_name
    answer = nil
    loop do
      puts "What is your name?"
      answer = gets.chomp
      break if answer.downcase.count(('a'..'z').to_a.join) > 0
      puts "Sorry, must have at least one letter."
    end

    human.set_name(answer)
  end

  def pick_computer_name
    answer = nil
    loop do
      puts "What is the computer's name?"
      answer = gets.chomp
      break if answer.downcase.count(('a'..'z').to_a.join) > 0
      puts "Sorry, must have at least one letter."
    end

    computer.set_name(answer)
  end

  def pick_marker
    answer = nil
    loop do
      puts "Would you like to be X or O?"
      answer = gets.chomp.upcase
      break if %w(X O).include?(answer)
      puts "Sorry, must be x or o."
    end

    human.set_marker(answer)
    computer.set_marker(human.marker == HUMAN_MARKER ? COMPUTER_MARKER : HUMAN_MARKER)
  end

  def display_final_result
    winner = case SCORE_TO_WIN
             when human.score    then "You"
             when computer.score then "Computer"
             else                     "No one"
             end

    puts "#{winner} scored #{SCORE_TO_WIN} points. #{winner} won the game!"
  end

  def clear_screen_and_display_board
    clear
    display_board
  end

  def human_turn?
    @current_marker == HUMAN_MARKER
  end

  def display_board
    puts "#{human.name} is #{human.marker}." \
         " #{computer.name} is #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def joinor(arr, delimiter=', ', word='or')
    case arr.size
    when 0 then ''
    when 1 then arr.first
    when 2 then arr.join(" #{word} ")
    else
      arr[-1] = "#{word} #{arr.last}"
      arr.join(delimiter)
    end
  end

  def human_moves
    puts "Choose a square between (#{joinor(board.unmarked_keys)}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    win_or_block_win ||
      take_middle ||
      make_double_threat ||
      block_double_threat ||
      take_corner ||
      take_anything
  end

  def make_move_if_valid(square)
    board[square] = computer.marker if square
    !!square
  end

  def win_or_block_win
    win || block_win
  end

  def win
    square = board.find_at_risk_keys(computer.marker).sample
    make_move_if_valid(square)
  end

  def block_win
    square = board.find_at_risk_keys(human.marker).sample
    make_move_if_valid(square)
  end

  def take_middle
    square = 5 if board.unmarked_keys.include?(5)
    make_move_if_valid(square)
  end

  def make_double_threat
    square = board.find_double_threat_keys(computer.marker).sample
    make_move_if_valid(square)
  end

  def block_double_threat
    double_threats = board.find_double_threat_keys(human.marker)
    square = if double_threats.size == 1
               double_threats
             elsif board[5].marker == computer.marker
               board.unmarked_keys.select(&:even?)
             end
    square = square.sample if square
    make_move_if_valid(square)
  end

  def take_corner
    square = board.unmarked_keys.select(&:odd?).sample
    make_move_if_valid(square)
  end

  def take_anything
    square = board.unmarked_keys.sample
    make_move_if_valid(square)
  end

  def current_player_moves
    if human_turn? then human_moves
    else                computer_moves
    end
  end

  def make_moves
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      alternate_player
      clear_screen_and_display_board if human_turn?
    end
  end

  def match_loop
    loop do
      display_board

      make_moves

      update_score if board.someone_won?
      display_result
      break if [human.score, computer.score].include?(SCORE_TO_WIN)
      break unless play_again?
      reset
      display_play_again_message
    end
  end

  def alternate_player
    @current_marker = case @current_marker
                      when HUMAN_MARKER    then COMPUTER_MARKER
                      when COMPUTER_MARKER then HUMAN_MARKER
                      end
  end

  def update_score
    case board.winning_marker
    when human.marker    then human.increment_score
    when computer.marker then computer.increment_score
    end
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "Computer won!"
    else
      puts "It's a tie!"
    end

    puts "Your score: #{human.score}"
    puts "Computer score: #{computer.score}"
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

  def clear
    system 'clear'
  end

  def reset
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end
end

game = TTTGame.new
game.play
