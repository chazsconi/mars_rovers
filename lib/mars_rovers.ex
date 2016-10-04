defmodule MarsRovers do
  defmodule OutOfBoundsError do
    defexception message: "rover moved outside of plateau"
  end

  def execute_commands(state, [], grid) do
    state
  end

  def execute_commands(state, [command | commands], grid) do
      execute_command(state, command, grid)
      |> execute_commands(commands, grid)
  end

  def execute_command({x, y, d}, "L", _) do
    case d do
      "N" -> {x, y, "W"}
      "S" -> {x, y, "E"}
      "E" -> {x, y, "N"}
      "W" -> {x, y, "S"}
    end
  end

  def execute_command({x, y, d}, "R", _) do
    case d do
      "N" -> {x, y, "E"}
      "S" -> {x, y, "W"}
      "E" -> {x, y, "S"}
      "W" -> {x, y, "N"}
    end
  end

  def execute_command({x, y, d}, "M", grid) do
    case d do
      "N" -> {x, y + 1, d}
      "S" -> {x, y - 1, d}
      "E" -> {x + 1, y, d}
      "W" -> {x - 1, y, d}
    end
    |> verify_in_bounds(grid)
  end

  def verify_in_bounds({x, y, d}, {max_x, max_y}) do
    if x in 0..max_x && y in 0..max_y do
      {x, y, d}
    else
      raise OutOfBoundsError
    end
  end
end
