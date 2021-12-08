defmodule BoardTest do
  use ExUnit.Case, async: true
  use PropCheck

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

  property "board contains rows * columns (size * size) spaces" do
    forall size <- pos_integer() do
      expected_spaces = size * size
      board = new(size)

      board.columns * board.rows == expected_spaces &&
        Enum.count(board.state) == expected_spaces
    end
  end

  property "there is no winner until at least 5 moves with the alternating pieces have been made" do
    # TODO Generalize for any size board, any # of pieces in a row to win
    forall {moves, num_moves} <- {non_empty(list({range(0,2), range(0,2)})), range(1,5)} do
      moves = Enum.slice(moves, 0, num_moves)
      board = apply_moves(moves, new(3))
      winner?(board, List.last(moves), 3) == nil
      true
    end
  end

  def apply_moves(moves, board) do
    # Arbitrarily start with :X
    apply_moves(moves, :X, board)
  end

  def apply_moves([], _piece, board), do: board
  def apply_moves([m | rest], piece, board) do
    new_board = case move(board, m, piece) do
      {:error, _reason} -> board
      new_board -> new_board
    end
    next_piece = case piece do
      :X -> :O
      :O -> :X
    end
    apply_moves(rest, next_piece, new_board)
  end
end
