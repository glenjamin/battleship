class GlenPlayer
  def name
    "Glen (search & destroy)"
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
    record_input(state, ships_remaining)
    record_output(fire!)
  end

  protected

  def record_input(state, ships_remaining)
    self.target_state = state
    self.ships_remaining << ships_remaining
    debug "result: #{last_shot_result}"
  end

  def record_output(coords)
    debug "firing at #{coords[0]},#{coords[1]}"
    self.salvo = coords
  end

  attr_accessor :salvo, :target_state, :ships_remaining
  def ships_remaining
    @ships_remaining ||= []
  end

  def fire!
    send(mode)
  end

  def mode
    @mode ||= :search
  end
  def mode!(mode)
    debug "mode = #{mode}"
    @mode = mode
    fire!
  end

  def search
    if last_shot_result == :hit and not last_shot_sunk
      mode!(:destroy)
    else
      possible.pop
    end
  end

  attr_accessor :last_hit
  def direction
    @direction ||= :up
  end
  def try_another_direction
    return @direction = :down if @direction == :up
    return @direction = :left if @direction == :down
    return @direction = :right if @direction == :left
    return @direction = :up if @direction == :right
  end

  def destroy
    if last_shot_sunk
      debug "Last shot sunk, returning to search"
      return mode!(:search)
    end
    debug "finding target"
    if last_shot_result == :hit
      debug "recording last hit at #{salvo[0]},#{salvo[1]}"
      self.last_hit = salvo
      target = follow(last_hit, direction)
    end
    i = 0
    if not target
      begin
        try_another_direction
        debug "now trying #{direction}"
        target = follow(last_hit, direction)
        break if (i+=1) > 4
      end while not target
    end
    if not target
      debug "got lost"
      @mode = :search
      return possible.pop
    end
    debug "target decided: #{target[0]},#{target[1]}"
    possible.delete(target)
  end

  def follow(from, direction)
    if look(from, direction) == :unknown
      relative(from, direction)
    elsif look(from, direction) == :hit
      follow(relative(from, direction), direction)
    end
  end

  def look(from, direction)
    x, y = relative(from, direction)
    if (0..9).include?(x) and (0..9).include?(y)
      target_state[y][x]
    end
  end

  def relative(from, direction)
    x, y = from
    x -=1 if direction == :left
    x +=1 if direction == :right
    y -=1 if direction == :up
    y +=1 if direction == :down
    [x, y]
  end

  def last_shot_result
    salvo and target_state[salvo[1]][salvo[0]]
  end
  def last_shot_sunk
    ships_remaining.length > 2 and
      ships_remaining[-2].length > ships_remaining[-1].length
  end

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

  def debug msg
    return unless ENV['DEBUG']
    log.puts "#{Process.pid} #{msg}"
    log.flush
  end
  def log
    @log ||= File.open('debug.log', 'a')
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
      return false
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
