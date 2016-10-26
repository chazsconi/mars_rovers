defmodule MarsRovers.Setup do
  alias MarsRovers.Rover
  alias MarsRovers.Plateau

  def deploy_rovers(rover_instructions, turns, delay \\ 0) do
    rover_pids = Enum.map(rover_instructions,
      fn(rover_init) ->
        deploy_rover(rover_init)
      end)
    :ok = run_turns(turns, delay)
    Enum.map(rover_pids, fn( rover_pid) -> Rover.state(rover_pid) end)
  end

  def deploy_rover(%Rover{}=rover_state, turns, delay \\ 0) do
    rover_pid = deploy_rover(rover_state)
    MarsRovers.PlateauVisualiserCLI.visualise
    IO.puts "Initial state"
    :ok = run_turns(turns, delay)
    Rover.state(rover_pid)
  end

  def deploy_rover(%Rover{}=rover_state) do
    rover_state
    |> Rover.new
    |> Plateau.add_rover
  end

  def run_turns(0, _delay), do: :ok
  def run_turns(turns, delay) do
    Plateau.run_turn
    slow_down(delay)
    run_turns(turns - 1, delay)
  end

  def slow_down(delay) do
    :timer.sleep(delay)
  end
end
