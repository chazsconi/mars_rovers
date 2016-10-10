defmodule MarsRovers do
  alias MarsRovers.Rover
  alias MarsRovers.Plateau

  def execute_commands({x, y, d}, commands, {max_x, max_y}) do
    state = Rover.execute_commands(%Rover{ x: x, y: y, d: d}, commands, %Plateau{max_x: max_x, max_y: max_y})
    {state.x, state.y, state.d}
  end
end
