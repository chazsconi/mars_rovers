defmodule MarsRovers do
  defmodule OutOfBoundsError do
    defexception message: "rover moved outside of plateau"
  end

  defmodule State do
    defstruct x: nil, y: nil, d: nil
  end

  def execute_commands({x, y, d}, commands, grid) do
    state = execute_commands(%State{ x: x, y: y, d: d}, commands, grid)
    {state.x, state.y, state.d}
  end

  def execute_commands(%State{}=state, [], _), do: state
  def execute_commands(%State{}=state, [command | commands], grid) do
      execute_command(state, command, grid)
      |> execute_commands(commands, grid)
  end

  def execute_command(%State{d: d}=state, "L", _) do
    case d do
      "N" -> %State{state | d: "W"}
      "S" -> %State{state | d: "E"}
      "E" -> %State{state | d: "N"}
      "W" -> %State{state | d: "S"}
    end
  end

  def execute_command(%State{d: d}=state, "R", _) do
    case d do
      "N" -> %State{state | d: "E"}
      "S" -> %State{state | d: "W"}
      "E" -> %State{state | d: "S"}
      "W" -> %State{state | d: "N"}
    end
  end

  def execute_command(%State{}=s, "M", grid) do
    case s.d do
      "N" -> %State{s | y: s.y + 1}
      "S" -> %State{s | y: s.y - 1}
      "E" -> %State{s | x: s.x + 1}
      "W" -> %State{s | x: s.x - 1}
    end
    |> verify_in_bounds(grid)
  end

  def verify_in_bounds(%State{x: x, y: y}=state, {max_x, max_y}) do
    if x in 0..max_x && y in 0..max_y do
      state
    else
      raise OutOfBoundsError
    end
  end
end
