require 'colorize'
# encoding: utf-8
require 'debugger'
module Chess

  DIAGONALS = [ [1,1], [1,-1], [-1,-1], [-1,1] ]
  HORIZONTALS = [ [1,0], [0,1], [-1, 0], [0, -1] ]
  KNIGHT_DIRS = [ [1, 2], [1, -2], [-1, 2], [-1, -2],
                  [2, 1], [2, -1], [-2, 1], [-2, -1]]

  MOVE_DIRECTIONS = {
    queen: DIAGONALS + HORIZONTALS,
    bishop: DIAGONALS,
    rook: HORIZONTALS,
    king: DIAGONALS + HORIZONTALS,
    knight: KNIGHT_DIRS
    #pawn is weird; do later
    }


  class Board
    attr_accessor :grid

    #later on add the feature that you can create a Board mid-game
    # => a filled grid(8x8)
    def Board.default_setup(board)
      grid = Array.new(8) { Array.new(8) }

      #could make more slick with better choice of iterators
      pawn_row = []
      [:white, :black].each do |color|
        8.times do |col|
          row = (color == :white) ? 1 : 6
          p = Pawn.new(color, [row, col], board)
          pawn_row << p
        end
      end

      grid[1], grid[6] = pawn_row.take(8), pawn_row.drop(8)


      piece_row = []
      [:white, :black].each do |color|
        8.times do |col|
          row = (color == :white) ? 0 : 7

          case col
          when 0 then p = Rook.new(color, [row, col], board)
          when 1 then p = Knight.new(color, [row, col], board)
          when 2 then p = Bishop.new(color, [row, col], board)
          when 3 then p = King.new(color, [row, col], board)
          when 4 then p = Queen.new(color, [row, col], board)
          when 5 then p = Bishop.new(color, [row, col], board)
          when 6 then p = Knight.new(color, [row, col], board)
          when 7 then p = Rook.new(color, [row, col], board)
          end

          piece_row << p
        end
      end

      grid[0], grid[7] = piece_row.take(8), piece_row.drop(8)

      grid
    end


    def initialize(grid = Board.default_setup(self))
      @grid = grid
    end

    def in_check?(color)

      kings_position = nil
      (0..7).each do |row|
        (0..7).each do |col|
          if (self[[row, col]].class == King && self[[row, col]].color == color)
            kings_position = [row, col]
            break
          end
          break if kings_position
        end
      end
      raise "No king on the board" if kings_position.nil?


      (0..7).any? do |row|
        (0..7).any? do |col|
          next if self[[row, col]].nil? || self[[row, col]].color == color

          self[[row, col]].moves.include?(kings_position)
        end
      end

    end

    def checkmate?(color)
      # is player in check?
      # if so, does any piece have any valid moves?
      return false unless in_check?(color)

      (0..7).all? do |row|
        (0..7).all? do |col|
          if self[[row, col]].nil? || self[[row, col]].color != color
            true
          else
            self[[row, col]].valid_moves.empty?
          end
        end
      end

      # checkmate = true
 #      if in_check?(color)
 #        (0..7).each do |row|
 #          (0..7).each do |col|
 #            if self[[row, col]].color == color
 #              checkmate = false if self[[row, col]].valid_moves.empty?
 #            end
 #          end
 #        end
 #      end
 #      checkmate
    end

    def move(start_pos, end_pos)
      # (1) get the piece from the start_pos
      # --> raise/rescue error if there is no piece in start_pos
      # (2) move the piece to the proper spot
      # --> raise/rescue error if the end_pos is not included in the piece's moves
      #   (2a) assign the board[end_pos] to the new piece
      #   (2b) assign the board[start_pos] to nil
      #   (2c) reassign the piece's position to end_pos

      piece_to_move = self[start_pos]
      raise InvalidMoveError.new "No piece in position" unless piece_to_move
      poss_moves = piece_to_move.valid_moves
      raise InvalidMoveError.new "Move Invalid" unless poss_moves.include?(end_pos)

      self.grid[end_pos.first][end_pos.last] = piece_to_move
      self.grid[start_pos.first][start_pos.last] = nil
      piece_to_move.position = end_pos

      nil
    end

    def [](position)
      x,y = position
      self.grid[x][y]
    end

    def dup
      # duplicate the outer array, the inner arrays, and the pieces contained in the inner arrays
      # (1) Duplicate the outer array and inner array (only one command needed)
      # (2)
      duped_grid = Array.new(8) {Array.new(8)}
      duped_board = Board.new(duped_grid)

      (0..7).each do |row|
        (0..7).each do |col|
          if self[[row, col]]
            # duped_grid[row][col] = self[[row, col]].dup_with_board(duped_board)
           #self[[row, col]] contains a piece
            duped_piece = self[[row, col]].dup
            duped_piece.board = duped_board
            duped_grid[row][col] = duped_piece
          end
        end
      end

      duped_board
    end

    def render

      displays = {
      [:black, :king] => "\u2654",
      [:black, :queen] => "\u2655",
      [:black, :bishop] => "\u2657",
      [:black, :knight] => "\u2658",
      [:black, :rook] => "\u2656",
      [:black, :pawn] => "\u2659",
      [:white, :king] => "\u2654".yellow,
      [:white, :queen] => "\u2655".yellow,
      [:white, :bishop] => "\u2657".yellow,
      [:white, :knight] => "\u2658".yellow,
      [:white, :rook] => "\u2656".yellow,
      [:white, :pawn] => "\u2659".yellow,
      }

      print "   "
      8.times {|i| print "#{i}  "}
      puts
      (0..7).each do |row|
        print "#{row}  "
        (0..7).each do |col|
          bgrd_white = ((row + col) % 2 == 0)

          piece = self.grid[row][col]
          if piece.nil?
            if (bgrd_white)
              print "   "
            else
              print "   ".on_white
            end
          else
            if (bgrd_white)
              piece = [piece.color, piece.piece_type]
              print " "+(displays[piece]+ " ")
            else
              piece = [piece.color, piece.piece_type]
              print " ".on_white+(displays[piece].on_white + " ".on_white)
            end
          end
        end
        puts
      end

      nil
    end


  end


  class Piece

    attr_reader :color, :position, :board, :piece_type
    #later refactor out this writer, and just add a dup method for each piece
    attr_writer :position, :board

    def initialize(color, position, board)
      @color, @position, @board = color, position, board
      @piece_type = nil
    end

    def moves
      raise "You haven't yet overwritten this method yet"
    end

    def inspect
      [self.piece_type, self.color, self.position].inspect
    end


    def valid_moves

      self.moves.reject { |move| move_into_check?(move) }
    end

    private
    def on_board?(pos)
      pos.first.between?(0,7) && pos.last.between?(0,7)
    end

    def not_blocked?(pos)
      return false unless on_board?(pos) #refactor this
      self.board[pos].nil? || (self.board[pos].color != self.color)
    end

    def move_into_check?(pos)
      #debugger

      duped_board = self.board.dup
      #refactor so that we just have a Piece#dup method
      duped_piece = self.dup
      duped_piece.board = duped_board

      # (1) duplicate the board

      # (2) move the piece into pos
      duped_board.grid[pos.first][pos.last] = duped_piece
      duped_board.grid[duped_piece.position[0]][duped_piece.position[1]] = nil
      duped_piece.position = pos
      # (3) return true if board.in_check?(own color)
      duped_board.in_check?(duped_piece.color)
    end


  end

  class SlidingPiece < Piece

    #q1 = Queen.new(:black, [7, 3], our_board)
    # q1.moves => [ [7,2], [7,1], [7,0], [6,3], [5,3],...  ]

    def initialize(color, position, board)
      super(color, position, board)

    end

    def moves
     directions = MOVE_DIRECTIONS[self.piece_type]
     multipliers = (1..7).to_a

     #directions = [ [1,1], [1,-1], [-1,1]  ]
     # multipliers = [1,2,3]
     #  Iter1 : dir --> dx=1,dy=1
     # ---> multipliers:
     # ----------> mult = 1
     #    new_arr << [1, 1]
     #   ----------> mult = 2
     #    new_arr << [2, 2]
     #    new_arr << [3, 3]
      #  Iter1 : dir --> dx=1,dy=-1
      # ----------> mult = 1
      #    new_arr << [1, -1]
      #   ----------> mult = 2
      #    new_arr << [2, -2]
      #    new_arr << [3, -3]
      # adders = [ [1,1], [2,2], [3,3], [1,-1], [2, -2], ...   ]

      # move_arr should not stop adding the moves in a direction that becomes blocked by a different piece:
      # break from the multipliers loop if the direction is blocked
      # --  if the current position is occupied by an other-colored piece
      # --- or if the subsequent position is occupied by a same-colored piece
      poss_moves = []

      directions.each do |(dx, dy)|
        multipliers.each do |mult|
          x, y = self.position

          cand_pos = [x + dx * mult, y + dy * mult]
          break if !(not_blocked?(cand_pos))

          poss_moves << cand_pos
          break if board[cand_pos] && (board[cand_pos].color != self.color)
        end
      end

      poss_moves.select { |coord| on_board?(coord) }


     #
     # directions.map do |(dx, dy)|
     #   multipliers.map do |mult|
     #      x, y = self.position
     #     [x + dx * mult, y + dy * mult]
     #
     #   end
     # end.flatten(1).select { |coord| on_board?(coord) }


    end
  end


  class SteppingPiece < Piece

    def initialize(color, position, board)
      super(color, position, board)

    end

    # k1 = King.new(....)

    # k1.moves
    # ---> k1.piece_type => :king
    # our_hash[:king] => an array of the directions a king can move in
    # Don't add the move to move_array if the space is occupied by a same-colored piece

    #FUTURE EDIT: we could make the boolean condition for select more slick
    def moves
      directions = MOVE_DIRECTIONS[self.piece_type]
      directions.map do |(dx, dy)|
        x, y = self.position
        [x + dx, y + dy]
      end.select { |coord| on_board?(coord) && not_blocked?(coord) }

      # cond = board[[coord]].nil? || board[[coord]].color != self.color
      # opp_cond = !(board[coord].color == self.color)
      # coord = [2,4]
      # [[2,3], nil, [3,4]]
      #(self.board[coord].color != self.color)
    end


  end

  class Queen < SlidingPiece

    def initialize(color, position, board)
      super(color, position, board)
      @piece_type = :queen
    end

   # def dup_with_board(board)
 #     Queen.new(self.color, self.position, board)
 #   end

  end

  class Bishop < SlidingPiece

    def initialize(color, position, board)
      super(color, position, board)
      @piece_type = :bishop
    end


  end

  class Rook < SlidingPiece

    def initialize(color, position, board)
      super(color, position, board)
      @piece_type = :rook
    end



  end

  class King < SteppingPiece
    def initialize(color, position, board)
      super(color, position, board)
      @piece_type = :king
    end



  end

  class Knight < SteppingPiece

    def initialize(color, position, board)
      super(color, position, board)
      @piece_type = :knight
    end


  end

  class Pawn < Piece

    def initialize(color, position, board)
      super(color, position, board)
      @piece_type = :pawn
    end

    # pawn always can move one step forward (unless same-color-blocked, opp-color-blocked or off board)
    # pawn can also move forward two steps if hasn't been moved before (unless same-color-blocked, opp-color-blocked or off board)
    # pawns can also move diagonal-forward if there is an opp-colored-piece there

    def moves
      moves = []

      x, y = self.position
      sign = self.color == :white ? 1 : -1
      init_row = self.color == :white ? 1 : 6

      one_up = [x + (1 * sign), y]
      two_up = [x + (2 * sign), y]

      moves << one_up if self.board[one_up].nil?

      if (self.board[one_up].nil? && self.board[two_up].nil? && self.position.first == init_row)
        moves << two_up
      end

      diag_left = [x + (1 * sign), y + 1]
      diag_right = [x + (1 * sign), y - 1]

      if self.board[diag_left] && self.board[diag_left].color != self.color
        moves << diag_left
      end

      if self.board[diag_right] && self.board[diag_right].color != self.color
        moves << diag_right
      end

      moves.select { |move| on_board?(move) }
    end


  end

  # class NoPieceFoundError < StandardError
  # end

  class InvalidMoveError < StandardError
  end

  class Game

    # def initialize(board = Board.new, player1 = HumanPlayer.new,
    #   player2 = HumanPlayer.new)
    #   @board = board
    #   @player1 = player1
    #   @player2 = player2
    # end

    def initialize(board = Board.new)
       @board = board
    end

    def play
      puts "Welcome to Chess"
      @board.render
      puts "Please enter your move by entering your start coordinates(e.g. 1,3)"
      puts "And then enter the end coordinates (e.g. 3,3)"
      #take moves loop
      turn_num = 0
      until(game_over?)
        puts turn_num.even? ? "White to move"  : "Black to move"

        begin
          print "Start position > "
          start_pos = gets.chomp.split(',').map(&:to_i)

          print "End position > "
          end_pos = gets.chomp.split(',').map(&:to_i)


          execute_move(start_pos, end_pos, turn_num)
        rescue InvalidMoveError => e
          puts "#{e.message}"
          puts "Please choose a valid move"
          retry
        end

        @board.render

        unless game_over?
          puts "White is in check" if @board.in_check?(:white)
          puts "Black is in check" if @board.in_check?(:black)
        end

        turn_num += 1
      end

      puts "Checkmate achieved!"
      puts turn_num.odd? ? "White wins"  : "Black wins"

    end

    def game_over?
      # come back later for draws
      @board.checkmate?(:black) || @board.checkmate?(:white)
    end

    def execute_move(start_pos, end_pos, turn_num)
      #check if piece at start_pos is of the right color (matches the turn number)
      color_to_move = (turn_num.even? ? :white : :black)
      if (@board[start_pos].color != color_to_move )
        raise InvalidMoveError.new("You must move a piece of your own color")
      end

      @board.move(start_pos, end_pos)
    end

  end

end