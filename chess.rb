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
      # find the right-colored king's position
      # -> nested iteration through whole grid, until grid[position] == KING
      # ---> if there is no king, raise error
      #
      # find if any other piece can move there
      # Algorithm1: iterate through every other-colored piece
      # -> if that piece's moves_array includes the King's position => in check
      # Algorithm2: starting at the king's square, go through all the ways a piece can move (e..g DIAGONALS, KNIGHTS_DIRs, etc.)
      # if, by moving in that direction, the KING could reach the square of an other-colored piece of the right type => in check (e.g. if by moving diagonally, the white King could reach a black bishop or a black Queen, then the King is in check)

    end

    def move(start_pos, end_pos)
      # (1) get the piece from the start_pos
      # --> raise/rescue error if there is no piece in start_pos
      # (2) move the piece to the proper spot
      # --> raise/rescue error if the end_pos is not included in the piece's moves
      #   (2a) assign the board[end_pos] to the new piece
      #   (2b) assign the board[start_pos] to nil
      #   (2c) reassign the piece's position to end_pos

    end

    def [](position)
      x,y = position
      self.grid[x][y]
    end


  end


  class Piece

    attr_reader :color, :position, :board, :piece_type

    def initialize(color, position, board)
      @color, @position, @board = color, position, board
      @piece_type = nil
    end

    def moves
      raise "You haven't yet overwritten this method yet"
    end

    def inspect
      [self.piece_type, self.color].inspect
    end

    private
    def on_board?(move_pos)
      move_pos.first.between?(0,7) && move_pos.last.between?(0,7)
    end

    def not_blocked?(pos)
      self.board[pos].nil? || (self.board[pos].color != self.color)
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

      if (self.board[one_up].nil? && self.board[two_up].nil?
        && self.position.first == init_row)
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

end