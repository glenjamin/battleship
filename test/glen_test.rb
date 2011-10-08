require "minitest/autorun"
require "battleship/board"

require File.expand_path("../../players/glen_player",  __FILE__)

class GlenTest < MiniTest::Unit::TestCase
  include Battleship

  def test_board_checks_invalid
    board = GlenPlayer::Board.new
    board.add [0, 0, 5, :down]
    board.add [0, 1, 5, :across]
    refute board.valid?
  end

  def test_board_checks_adjacent
    board = GlenPlayer::Board.new
    board.add [0, 0, 5, :across]
    board.add [0, 1, 2, :across]
    refute board.valid?
  end

  def test_board_checks_valid
    board = GlenPlayer::Board.new
    board.add [0, 0, 5, :across]
    board.add [1, 2, 5, :down]
    assert board.valid?
  end

  def test_valid_layouts
    50.times do
      glen = ::GlenPlayer.new
      board = Board.new(10, [5,4,3,3,2], glen.new_game)
      assert board.valid?, board.inspect
    end
  end

end
