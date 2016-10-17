defmodule MarsRovers do
  alias MarsRovers.Rover
  alias MarsRovers.Plateau

  def setup(plateau_limits) do
    :ok = Plateau.create(plateau_limits)
    {:ok, pid} = GenEvent.start_link(name: :event_manager)
    :ok = GenEvent.add_handler(pid, MarsRovers.PlateauVisualiserCLI, [])
  end

  def deploy_rovers(rover_instructions, plateau_limits, turns) do
    setup(plateau_limits)
    rover_pids = Enum.map(rover_instructions,
      fn(rover_init) ->
        deploy_rover(rover_init)
      end)
    :ok = run_turns(turns)
    Enum.map(rover_pids, fn( rover_pid) -> Rover.state(rover_pid) end)
  end

  def deploy_rover(%Rover{}=rover_state, {_,_}=plateau_limits, turns) do
    :ok = setup(plateau_limits)
    rover_pid = deploy_rover(rover_state)
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
    IO.puts "Turns #{turns}"
    Plateau.run_turn
    slow_down
    run_turns(turns - 1)
  end

  def slow_down do
    :timer.sleep(50)
  end
end
