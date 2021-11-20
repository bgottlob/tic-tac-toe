defmodule TicTacToe.Core.Game do
  alias TicTacToe.Core.Board

  defstruct turn: 0, players: {:X, :O}, board: Board.new(3), winner: nil

  def new() do
    struct!(__MODULE__, %{})
  end
end
