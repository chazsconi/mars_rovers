defmodule MarsRovers do
  alias MarsRovers.Rover
  alias MarsRovers.Plateau

  def deploy_rovers(plateau_limits, rover_instructions) do
    :ok = Plateau.create(plateau_limits)
    Enum.map(rover_instructions,
      fn({rover_init, commands}) ->
        deploy_rover(rover_init, commands)
      end)
  end

  def deploy_rover(%Rover{}=rover_state, commands, plateau_limits) do
    :ok = Plateau.create(plateau_limits)
    deploy_rover(rover_state, commands)
  end

  def deploy_rover(%Rover{}=rover_state, commands) do
    rover_state
    |> Rover.new
    |> Plateau.add_rover
    |> execute_commands(commands)
    |> Rover.state
  end

  def execute_commands(rover_pid, []), do: rover_pid
  def execute_commands(rover_pid, [command | commands]) do
    rover_pid
    |> Rover.execute_command(command)
    |> execute_commands(commands)
  end
end
