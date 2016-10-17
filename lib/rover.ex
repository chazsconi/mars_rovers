defmodule MarsRovers.Rover do
  use GenServer
  require Logger
  alias MarsRovers.Rover
  alias MarsRovers.Plateau

  defstruct x: nil, y: nil, d: nil, commander: nil, command_queue: [], last_move_valid: true

  # Client API
  @doc "Creates a new rover"
  def new(%Rover{}=rover) do
    {:ok, pid} = GenServer.start_link(Rover, rover)
    pid
  end

  def execute_command(pid) do
    :ok = GenServer.call(pid, :execute_command)
    GenEvent.notify(:event_manager, :rover_moved)
    pid
  end

  @doc "Returns the rover's state"
  def state(pid) do
    GenServer.call(pid, :state)
  end

  # Server API
  def handle_call(:execute_command, _from, state) do
    state = do_execute_command(state)
    {:reply, :ok, state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  # Command queue is empty, reload it
  defp do_execute_command(%Rover{command_queue: [], commander: commander}=s) do
    %Rover{s | command_queue: commander.on_idle}
    |> do_execute_command
  end

  defp do_execute_command(%Rover{d: d, command_queue: ["L" | commands]}=s) do
    case d do
      "N" -> %Rover{s | d: "W", command_queue: commands}
      "S" -> %Rover{s | d: "E", command_queue: commands}
      "E" -> %Rover{s | d: "N", command_queue: commands}
      "W" -> %Rover{s | d: "S", command_queue: commands}
    end
  end

  defp do_execute_command(%Rover{d: d, command_queue: ["R" | commands]}=s) do
    case d do
      "N" -> %Rover{s | d: "E", command_queue: commands}
      "S" -> %Rover{s | d: "W", command_queue: commands}
      "E" -> %Rover{s | d: "S", command_queue: commands}
      "W" -> %Rover{s | d: "N", command_queue: commands}
    end
  end

  defp do_execute_command(%Rover{command_queue: ["M" | commands]}=s) do
    case Plateau.move_rover(s) do
      {:ok, {new_x, new_y}}  -> %Rover{ s | last_move_valid: true, x: new_x, y: new_y, command_queue: commands}
      {:wall_collision, wall} ->
        %Rover{ s | last_move_valid: false}
        |> wall_collision(wall)
    end
  end

  defp wall_collision(%Rover{commander: commander}=state, wall) do
    %Rover{state | command_queue: commander.on_wall_collision(wall)}
  end
end
