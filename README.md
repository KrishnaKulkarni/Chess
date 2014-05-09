Chess
=====
A command-prompt chess game.


The program is an extensive exercise in OOP for DRY creation of legally-moving pieces (Note: There's a natural hierarchy in
chess from generic Pieces to Sliding/Stepping Pieces to specific types of pieces) and uses JSON serialization
for file-saving and loading as well as thoughtful algorithms to speed up sophisticated functions such as checking for check,
checkmate, and valid castling.

On the horizon
-------------
Developing a Javascript front end to enable players to play against other players in the browser, save their games, and 
develop an ELO rating.
