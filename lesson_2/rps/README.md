# Rock, Paper, Scissors

## Gameplay

This is the ''Rock, Paper, Scissors, Lizard, Spock" variation of the game.

In line with this variation, the possible **moves** are Rock, Paper, Scissors, Lizard, or Spock.

Walkthrough:

- The player is asked to enter their name.
- The player is asked to choose an opponent. (They are given a list of options to choose from. They can also choose to have an opponent randomly selected for them. Each opponent has different 'personalities'. This means that each move does not necessarily have the same probability of being chosen by two different opponents.)
- A welcome message is displayed.
- The user is asked to choose their move.
- The details of the round are displayed:
  - The round number. (The program keeps track of the number of rounds within a match.)
  - The user's choice.
  - The opponent's choice.
  - The outcome of the round.
  - The user's current score.
  - The opponent's current score.
- Each time someone wins a round, their score for the match is incremented.
- This process is repeated until the match is over. (The first to win 10 rounds (default) wins the match. The number of rounds to win a match can be set by modifying the `MATCH_WIN_SCORE` constant within the `Match` class in the  `oo_rps.rb`  source code file.)
- After the match is over, the user is asked if they would like to review any of the matches they've played during the program's current running session.
  - If they choose to review:
    - The user is asked to enter the number of the match they would like to review.
    - The user can enter 'q' before/after each review of a match to stop reviewing.
    - For each match review, the following is displayed:
      - The match number and the number of rounds in that match. (The user presses enter to continue.)
      - Each round in that match, one by one. (The user presses enter to view the next round. The rounds are displayed in the same manner as when they were first played.)
      - The winner of that match.
    - This process is repeated until the user quits by entering 'q'.
- At this point, the user has chosen to not review games, or they have stopped reviewing games.
- The user is asked if they would like to play another match.
  -  If they choose yes, their scores will be reset and a new match will begin.
  - If they choose no, the program finishes execution with a goodbye message.

## Object Oriented Design Notes

### Classes

- `Move` - This class provides comparison methods that only require the subclasses to define a `wins?` method.
  - The `Move` class has five subclasses: `Rock`, `Paper`, `Scissors`, `Lizard`, and `Spock`. These classes provide two methods: a `wins?` method that is required by the superclass `Move` so that they can be compared with each other, and a `to_s` method.
- `Player` - This class provides the ability to keep track of a player's name, move choice, and score.
  - The `Player` class has six subclasses: `Human`, `R2D2`, `Hal`, `Chappie`, `Sonny`, and `Number5`. Each of these subclasses provide a `set_name` method, required by the `initialize` method in the `Player` class. They are also responsible for the process of choosing moves during each round.
- `Round` - The responsibilities of this class are to keep track of the number of rounds in the current match, orchestrate the playing of each round, and save the relevant details of each round for review in the future.
- `Match` - This class keeps track of all the rounds that have been played during each match, saving them for later review. This class also orchestrates the playing of a match and determining its outcome.
- `RPSGame` - This class orchestrates the overall flow of the game. It keeps track of all the matches that have been played.

### Modules

- `Displayable` - This module provides methods related the user interface. It has useful methods for nicely displaying output to the console and getting user input.