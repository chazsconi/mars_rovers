defmodule MarsRovers do
  defmodule State do
    defstruct x: nil, y: nil, d: nil, last_move_valid: true
  end

  def execute_commands({x, y, d}, commands, grid) do
    state = execute_commands(%State{ x: x, y: y, d: d}, commands, grid)
    {state.x, state.y, state.d}
  end

  def execute_commands(%State{}=state, [], _), do: state
  def execute_commands(%State{}=state, [command | commands], grid) do
      state
      |> execute_command(command, grid)
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
    {new_x,new_y} = new_position(s)
    case verify_in_bounds({new_x, new_y}, grid) do
      :ok    -> %State{ s | x: new_x, y: new_y, last_move_valid: true}
      :error -> %State{ s | last_move_valid: false}
    end
  end

  defp new_position(%State{}=s) do
    case s.d do
      "N" -> {s.x, s.y + 1}
      "S" -> {s.x, s.y - 1}
      "E" -> {s.x + 1, s.y}
      "W" -> {s.x - 1, s.y}
    end
  end

  defp verify_in_bounds({x, y}, {max_x, max_y}) do
    if x in 0..max_x && y in 0..max_y, do: :ok, else: :error
  end
end
