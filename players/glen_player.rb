class GlenPlayer
  def name
    "Glen"
  end

  def new_game
    begin
      board = Board.new
      board.add random_ship(5, 10)
      board.add random_ship(4, 10)
      board.add random_ship(3, 10)
      board.add random_ship(3, 10)
      board.add random_ship(2, 10)
    end until board.valid?
    return board.ships
  end

  def take_turn(state, ships_remaining)
    possible.pop
  end

  protected

  def possible
    @possible ||= begin
      cross(0.upto(9), 0.upto(9)).shuffle
    end
  end

  def random_ship(size, grid)
    direction = [:across, :down].sample
    xrange = grid - (direction == :across ? size : 0)
    yrange = grid - (direction == :down ? size : 0)
    return [rand(xrange), rand(yrange), size, direction]
  end

  class Board
    def ships
      @ships ||= []
    end
    def expanded
      @expanded ||= []
    end
    def add(ship)
      ships << ship
      full_ship = []
      x, y, size, direction = ship
      0.upto(size - 1) do |i|
        full_ship << [x + (direction == :across ? i : 0),
                      y + (direction == :down ? i : 0)]
      end
      expanded << full_ship
    end
    def valid?
      expanded.each_with_index do |ship1, i|
        others = expanded.dup; others.delete_at(i)
        others.each do |ship2|
          return false if adjacent_ships(ship1, ship2)
        end
      end
      return true
    end
    private
    def adjacent_ships(ship1, ship2)
      cross(ship1, ship2).each do | a, b |
        return true if adjacent_cells(a,b)
      end
      return false
    end
    def adjacent_cells(a, b)
      return true if a == b
      return true if a[0] == b[0] and a[1]+1 == b[1]
      return true if a[0] == b[0] and a[1]-1 == b[1]
      return true if a[1] == b[1] and a[0]+1 == b[0]
      return true if a[1] == b[1] and a[0]-1 == b[0]

    end
  end

end

def cross(a,b)
  c = []
  a.each do |x|
    b.each do |y|
      c << [x,y]
    end
  end
  return c
end
