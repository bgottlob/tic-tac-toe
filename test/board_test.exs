defmodule BoardTest do
  use ExUnit.Case, async: true

  alias TicTacToe.Core.Board
  import TicTacToe.TestHelper
  import TicTacToe.Core.Board

  test "creation of a blank Tic-Tac-Toe board (3 x 3)" do
    board = new(3)

    assert board.rows == 3
    assert board.columns == 3
    assert board.state == %{
      {0,0} => nil,
      {0,1} => nil,
      {0,2} => nil,
      {1,0} => nil,
      {1,1} => nil,
      {1,2} => nil,
      {2,0} => nil,
      {2,1} => nil,
      {2,2} => nil
    }
  end

  test "list remaining open moves" do
    board =
      new(3)
      |> move({0,0}, :O)
      |> move({1,0}, :X)
      |> move({1,2}, :O)
      |> move({2,1}, :X)

    assert open_moves(board) == [{0,1}, {0,2}, {1,1}, {2,0}, {2,2}]
  end

  test "render board as a string" do
    assert Board.to_string(new(3)) == """
    ---
    ---
    ---
    """
    |> trim_multiline()

    board =
      new(3)
      |> move({0,0}, :O)
      |> move({1,0}, :X)
      |> move({1,2}, :O)
      |> move({2,1}, :X)

    assert Board.to_string(board) == """
    -O-
    --X
    OX-
    """
    |> trim_multiline()
  end

  test "winner detection" do
    assert_winning_move = fn board, coord, piece, expected_winner ->
      board = move(board, coord, piece)
      assert winner?(board, coord, 3) == expected_winner
      board
    end

    refute_winning_move = fn board, coord, piece ->
      assert_winning_move.(board, coord, piece, nil)
    end

    new(3)
    |> refute_winning_move.({0,0}, :X)
    |> refute_winning_move.({0,1}, :O)
    |> refute_winning_move.({1,0}, :X)
    |> refute_winning_move.({1,1}, :O)
    |> assert_winning_move.({2,0}, :X, :X)
  end
end
