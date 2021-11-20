defmodule TicTacToe.Core.Board do
  defstruct [:rows, :columns, :state]

  def new(size) do
    new(size, size)
  end

  defp new(rows, columns) do
    state =
      coordinate_list(rows, columns)
      |> Enum.reduce(%{}, fn coord, board -> Map.put(board, coord, nil) end)

    struct!(__MODULE__, %{rows: rows, columns: columns, state: state})
  end

  defp coordinate_list(rows, columns) do
    for x <- 0..(rows - 1), y <- 0..(columns-1), do: {x,y}
  end

  defp sort_coordinates(coords) do
    Enum.sort(coords, fn
      {x_1,_}, {x_2,_} when x_1 >= x_2 -> true
      {x,y_1}, {x,y_2} when y_1 >= y_2 -> true
      {x,y}, {x,y}                     -> true # won't actually happen
      _, _                             -> false
    end)
  end

  def to_string(board) do
    coordinate_list(board.rows, board.columns)
    |> sort_coordinates()
    |> Stream.map(fn coord ->
      case Map.fetch!(board.state, coord) do
        nil -> "-"
        atom -> Atom.to_string(atom)
      end
    end)
    |> Stream.chunk_every(board.columns)
    |> Enum.join("\n")
  end

  def move(_board, _coord, nil) do
    {:error, "Invalid piece"}
  end

  def move(_board, _coord, piece) when not is_atom(piece) do
    {:error, "Invalid piece"}
  end

  def move(%__MODULE__{rows: rows, columns: cols}, {x,y}, _piece)
    when x < 0 or y < 0 or x >= rows or y >= cols do
      {:error, "Invalid coordinate"}
  end

  def move(board, coord, piece) do
    case Map.fetch!(board.state, coord) do
      nil ->
        Map.put(
          board,
          :state,
          Map.put(board.state, coord, piece)
        )
      _ -> {:error, "Coordinate is not open"}
    end
  end

  def open_moves(board) do
    board.state
    |> Map.keys()
    |> Enum.filter(&(Map.fetch!(board.state, &1) == nil))
  end
end
