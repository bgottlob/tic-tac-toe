defmodule TicTacToe.Core.Game do
  alias TicTacToe.Core.Board

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

  def check_winner(game, coord) do
    case Board.winner?(game.board, coord, game.to_win) do
      nil -> game
      winner -> Map.put(game, :winner, winner)
    end
  end

  def move(game, coord) do
    case Board.move(game.board, coord, player_turn(game)) do
      {:error, reason} ->
        IO.puts(reason)
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
    "Winner: #{game.winner}\nTurn: #{player_turn(game)}\n#{Board.to_string(game.board)}"
  end
end
