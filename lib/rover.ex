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
  defp do_execute_command(%Rover{command_queue: [], commander: commander}=state) do
    %Rover{state | command_queue: commander.on_idle}
    |> do_execute_command
  end

  defp do_execute_command(%Rover{command_queue: [command | commands]}=state) do
    state = do_execute_command(state, command)
    %Rover{ state | command_queue: commands}
  end

  defp do_execute_command(%Rover{d: d}=state, "L") do
    case d do
      "N" -> %Rover{state | d: "W"}
      "S" -> %Rover{state | d: "E"}
      "E" -> %Rover{state | d: "N"}
      "W" -> %Rover{state | d: "S"}
    end
  end

  defp do_execute_command(%Rover{d: d}=state, "R") do
    case d do
      "N" -> %Rover{state | d: "E"}
      "S" -> %Rover{state | d: "W"}
      "E" -> %Rover{state | d: "S"}
      "W" -> %Rover{state | d: "N"}
    end
  end

  defp do_execute_command(%Rover{}=s, "M") do
    case Plateau.move_rover(s) do
      {:ok, {new_x, new_y}}  -> %Rover{ s | last_move_valid: true, x: new_x, y: new_y}
      {:error, _}            -> %Rover{ s | last_move_valid: false}
    end
  end
end
