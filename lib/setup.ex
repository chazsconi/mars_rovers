defmodule MarsRovers.Setup do
  alias MarsRovers.Rover
  alias MarsRovers.Plateau

  def deploy_rovers(rover_instructions, turns) do
    rover_pids = Enum.map(rover_instructions,
      fn(rover_init) ->
        deploy_rover(rover_init)
      end)
    :ok = run_turns(turns)
    Enum.map(rover_pids, fn( rover_pid) -> Rover.state(rover_pid) end)
  end

  def deploy_rover(%Rover{}=rover_state, turns) do
    rover_pid = deploy_rover(rover_state)
    MarsRovers.PlateauVisualiserCLI.visualise
    IO.puts "Initial state"
    :ok = run_turns(turns)
    Rover.state(rover_pid)
  end

  def deploy_rover(%Rover{}=rover_state) do
    rover_state
    |> Rover.new
    |> Plateau.add_rover
  end

  def run_turns(0), do: :ok
  def run_turns(turns) do
    IO.puts "Turn start #{turns}"
    Plateau.run_turn
    slow_down
    run_turns(turns - 1)
  end

  def slow_down do
    :timer.sleep(50)
  end
end
