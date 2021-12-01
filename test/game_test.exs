defmodule GameTest do
  use ExUnit.Case, async: true

  alias TicTacToe.Core.Game
  import TicTacToe.Core.Game

  test "an invalid move attempt does not advance to the next player's turn" do
    game = move(new(), {0,0})
    turn = game.turn

    # Make an invalid move
    game = move(game, {0,0})
    assert game.turn == turn

    # Make a valid move, advance to a different player
    game = move(game, {1,0})
    assert game.turn != turn
  end

  test "a winner is not set until the winning move is made" do
    assert_winning_move = fn game, coord, expected_winner ->
      game = move(game, coord)
      assert game.winner == expected_winner
      game
    end

    refute_winning_move = fn game, coord ->
      assert_winning_move.(game, coord, nil)
    end

    new() # X fills out the first row before O gets a third move
    |> refute_winning_move.({0,0})     # X move (X is first by default)
    |> refute_winning_move.({0,1})     # O move
    |> refute_winning_move.({1,0})     # X move
    |> refute_winning_move.({1,1})     # O move
    |> assert_winning_move.({2,0}, :X) # X move
  end

  test "render game as a string before a winner is declared" do
    game =
      new()
      |> move({1,1})
      |> move({0,1})
      |> move({0,0})
      |> move({1,2})

    expected = """
    Winner: None
    Turn: X
    -O-
    OX-
    X--
    """
    |> String.split("\n")
    |> Enum.map(&(String.trim(&1)))
    |> Enum.join("\n")
    |> String.trim()

    actual = Game.to_string(game)

    assert actual == expected, "Actual:\n#{actual}\nExpected:\n#{expected}"
  end

  test "render game as a string after a winner is declared" do
    game =
      new()
      |> move({1,1})
      |> move({0,1})
      |> move({0,0})
      |> move({1,2})
      |> move({2,2})

    expected = """
    Winner: X
    Turn: None
    -OX
    OX-
    X--
    """
    |> String.split("\n")
    |> Enum.map(&(String.trim(&1)))
    |> Enum.join("\n")
    |> String.trim()

    actual = Game.to_string(game)

    assert actual == expected, "Actual:\n#{actual}\nExpected:\n#{expected}"
  end
end
