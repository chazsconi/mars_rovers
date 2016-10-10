defmodule MarsRovers do
  alias MarsRovers.Rover
  alias MarsRovers.Plateau

  def deploy_rovers(plateau_limits, rover_instructions) do
    plateau = create_plateau(plateau_limits)
    Enum.map(rover_instructions,
      fn({rover_init, commands}) ->
        execute_commands(rover_init, commands, plateau)
      end)
  end

  def create_plateau({max_x, max_y}) do
    %Plateau{max_x: max_x, max_y: max_y}
  end

  def create_rover({x, y, d}) do
    %Rover{ x: x, y: y, d: d}
  end

  def execute_commands(rover_init, commands, %Plateau{}=plateau) do
    state =
      rover_init
      |> create_rover
      |> Rover.execute_commands(commands, plateau)
    {state.x, state.y, state.d}
  end
  def execute_commands(rover_init, commands, plateau_limits) do
    execute_commands(rover_init, commands, create_plateau(plateau_limits))
  end
end
