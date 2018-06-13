# pico8
Games made using pico-8.

### Othello (WIP)
Similar to the board game Othello or Reversi. Cat and original theme available.
#####   Rules:
    * Board is a set of 8x8 tiles
    * To start, 4 tokens (2 from each player) are placed in the middle 2x2 tiles of the board. No same-sided token can be side-by-side
    * To place a token, it must be along the same row, column, or diagonal as any one of the current player's tokens.
        * It must be next to or diagonal to at least one other token
        * There must be at least one of the opposing player's tokens between the new token and one of the current player's tokens.
    * After placing the token, all of the opposing player's tokens that lie between the new token and the current player's tokens will flip.
    * When no more valid moves are available to either player, the game ends and the player with the most tokens wins.
