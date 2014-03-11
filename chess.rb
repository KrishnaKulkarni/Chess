module Chess

MOVE_DIRECTIONS = {

  Queen: [[  ]




}

DIAGONALS = [ [1,1], [1,-1], [-1,-1], [-1,1] ]
HORIZONTALS = [ [1,0], [0,1], [-1, 0], [0, -1] ]


  class Piece
    def initialize(color, position, board)
    end

    def moves
    end


  end

  class SlidingPiece < Piece

    def moves
    end


  end


  class SteppingPiece < Piece

    def moves
    end


  end

  class Queen < SlidingPiece

    def moves
    end

  end

  class Bishop < SlidingPiece

  end

  class Rook < SlidingPiece
  end

  class King < SteppingPiece
  end

  class Knight < SteppingPiece
  end

  class Pawn
  end

end