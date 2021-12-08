ExUnit.start()

defmodule TicTacToe.TestHelper do
  def trim_multiline(str) do
    str
    |> String.split("\n")
    |> Enum.map(&(String.trim(&1)))
    |> Enum.join("\n")
    |> String.trim()
  end
end
