# Lines of Action

## Game Description

Paraphrasing from [Wikipedia](https://en.wikipedia.org/wiki/Lines_of_Action):

Lines of Action (or LOA) is an abstract strategy board game for two players invented by Claude Soucie. The objective is to connect all of one's pieces into a single group. The object of the game is to bring all of one's pieces together into a contiguous body so that they are connected vertically, horizontally or diagonally.

Movement Summary:

- Players alternate moves, with Black having the first move.
- Pieces move horizontally, vertically, or diagonally.
- A piece moves exactly as many spaces as there are pieces (both friendly and enemy) on the line in which it is moving.
- A piece may not jump over an enemy piece.
- A piece may jump over friendly pieces.
- A piece may land on a square occupied by an enemy piece, resulting in the latter's capture and removal from the game.
- A player who is reduced to a single piece wins the game, because his pieces are by definition united.
- If a move results, due to a capture, in each player having all his pieces in a contiguous body, then either the player moving wins, or the game is a draw, depending on the rules in force at the particular tournament.

## This implementation

This is my implementation of Lines of Action. It's developed in SwiftUI and includes both a single-player mode and a local, two-player mode.

<img src="https://user-images.githubusercontent.com/8823138/219982933-dcec8f17-2e26-4536-9249-d141fbb12489.PNG" width=200 />

Players can make and undo legal moves.

<img src="https://user-images.githubusercontent.com/8823138/219982945-23f834bc-46b0-4087-90cc-5d8024fcfb27.PNG" width=200 />
<img src="https://user-images.githubusercontent.com/8823138/219982954-ef5e3579-d323-4648-b287-335a7fc7b57e.PNG" width=200 />

Players can view the opponent's most recent move.

<img src="https://user-images.githubusercontent.com/8823138/219983063-b04c2722-eb91-47e2-b029-da1e0d8de0bb.PNG" width=200 />

Players can change the player names, the color scheme for the board and pieces, and the icon used on the top of each piece.

<img src="https://user-images.githubusercontent.com/8823138/219983008-e4282a6b-6bf4-4cc2-b550-49ec0256e550.PNG" width=200 />

After a game finishes, either because a player won or a player conceded, the game moves to an analysis mode, which allows users to view all moves executed during the course of play.

<img src="https://user-images.githubusercontent.com/8823138/219983124-c6d391fb-d67a-4f6f-b166-823ea504e5f6.PNG" width=200 />

In local two-player mode, players alternate controlling first one color and then the other.

<img src="https://user-images.githubusercontent.com/8823138/219983148-7e231d09-5827-4950-9cf9-5a1a32df6817.PNG" width=200 />

In single-player mode, players battle a heuristic-based minimax agent that considers and applies [various strategies devised by LOA researchers](https://www.chessprogramming.org/Lines_of_Action).
