defmodule TicTacToe.Core.Game do
  alias TicTacToe.Core.Board

  require Logger

  defstruct turn: 0,
    players: {:X, :O},
    board: Board.new(3),
    winner: nil,
    to_win: 3

  def new() do
    struct!(__MODULE__, %{})
  end

  # Get the player whose turn it currently is
  defp player_turn(game) do
    elem(game.players, game.turn)
  end

  defp next_turn(game) do
    Map.update!(
      game,
      :turn,
      fn turn ->
        Integer.mod(turn + 1, tuple_size(game.players))
      end
    )
  end

  defp check_winner(game, coord) do
    Map.put(
      game,
      :winner,
      Board.winner?(game.board, coord, game.to_win)
    )
  end

  def move(game, coord) do
    case Board.move(game.board, coord, player_turn(game)) do
      {:error, reason} ->
        Logger.warn(reason)
        game # Move is not executed, game is unchanged
      new_board ->
        # Move is executed, update board and player turn
        game
        |> Map.put(:board, new_board)
        |> check_winner(coord)
        |> next_turn()
    end
  end

  def to_string(game) do
    turn = case game.winner do
      nil -> player_turn(game)
      _   -> "None"
    end

    "Winner: #{game.winner || "None"}\n" <>
      "Turn: #{turn}\n" <>
        "#{Board.to_string(game.board)}"
  end
end
