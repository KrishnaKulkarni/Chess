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



  class Piece

    attr_reader :color, :position, :board, :piece_type

    def initialize(color, position, board)
      @color, @position, @board = color, position, board
      @piece_type = nil
    end

    def moves
      raise "You haven't yet overwritten this method yet"
    end

    private
    def on_board?(move_pos)
      move_pos.first.between?(0,7) && move_pos.last.between?(0,7)
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

     directions.map do |(dx, dy)|
       multipliers.map do |mult|
          x, y = self.position
         [x + dx * mult, y + dy * mult]

       end
     end.flatten(1).select { |coord| on_board?(coord) }


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
    def moves
      directions = MOVE_DIRECTIONS[self.piece_type]
      directions.map do |(dx, dy)|
        x, y = self.position
        [x + dx, y + dy]
      end.select { |coord| on_board?(coord) }

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
  end

end