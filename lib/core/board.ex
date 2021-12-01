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

  # Sorts coordinates for the purposes of rendering the board
  # Descending by row, then ascending by column
  defp sort_coordinates(coords) do
    Enum.sort(coords, fn
      {_,y_1}, {_,y_2} when y_1 >= y_2 -> true
      {x_1,y}, {x_2,y} when x_1 <= x_2 -> true
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

  def winner?(board, root_coord, to_win) do
    # TODO piece cannot be nil!
    piece = Map.fetch!(board.state, root_coord)
    directions = [:vertical, :horizontal, :diagonal, :back_diagonal]
    have_winner = 
      directions
      |> Stream.map(fn direction ->
        dfs(board.state, piece, direction, root_coord, MapSet.new())
      end)
      |> Enum.any?(fn path_set ->
      # to_win = 3 for Tic-Tac-Toe
        MapSet.size(path_set) >= to_win
      end)

    if have_winner do
      piece
    else
      nil
    end
  end

  defp possible_neighbors(:vertical,      {x,y}), do: [{x,  y+1}, {x,  y-1}]
  defp possible_neighbors(:horizontal,    {x,y}), do: [{x+1,y  }, {x-1,y  }]
  defp possible_neighbors(:diagonal,      {x,y}), do: [{x+1,y-1}, {x-1,y+1}]
  defp possible_neighbors(:back_diagonal, {x,y}), do: [{x+1,y+1}, {x-1,y-1}]

  defp neighbors(state, piece, direction, coord, visited) do
    possible_neighbors(direction, coord)
    |> Stream.filter(fn neighbor -> # don't re-visit coordinates
      !MapSet.member?(visited, neighbor)
    end)
    |> Enum.filter(fn neighbor ->
      # Has the effect of removing coordinates with pieces that do not match
      # the current AND out of bounds coordinates
      Map.get(state, neighbor) == piece
    end)
  end

  defp dfs(state, piece, direction, coord, visited) do
    visited = MapSet.put(visited, coord)
    case neighbors(state, piece, direction, coord, visited) do
      [] ->
        visited
      neighbors ->
        Enum.reduce(neighbors, visited, fn neighbor, acc ->
          MapSet.union(acc, dfs(state, piece, direction, neighbor, visited))
        end)
    end
  end
end
