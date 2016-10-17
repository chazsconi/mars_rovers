defmodule MarsRovers.Plateau do
  use GenServer
  alias MarsRovers.Plateau
  alias MarsRovers.Rover
  defstruct max_x: nil, max_y: nil, rovers: []

  defmodule VisualState do
    defstruct cells: %{}, size: {0,0}
  end

  # Client API
  @doc "Creates the Plateau and registers the process as Plateau"
  def create({max_x, max_y}) do
    {:ok, _pid} = GenServer.start_link(Plateau,%Plateau{max_x: max_x, max_y: max_y}, [name: Plateau])
    :ok
  end

  @doc "Adds a rover to the Plateau"
  def add_rover(rover_pid) do
    :ok = GenServer.call(Plateau, {:add_rover, rover_pid})
    rover_pid
  end

  @doc "Attempts to move a rover on the plateau.  Updates the rovers position or sets last_move_valid to false"
  def move_rover(%Rover{} = rover_state) do
    result = GenServer.call(Plateau, {:move_rover, rover_state})
    result
  end

  @doc "Runs a turn on the plateau"
  def run_turn do
    state.rovers
    |> run_turn_for_each_rover
  end

  def state do
    GenServer.call(Plateau, :state)
  end

  def visual_state do
    state = state()
    cells =
      Enum.reduce(state.rovers, %{}, fn(rover_pid, acc) ->
        rover_state = Rover.state(rover_pid)
        Map.put(acc, {rover_state.x, rover_state.y}, rover_state)
      end)
    %VisualState{ cells: cells, size: {state.max_x, state.max_y}}
  end

  # Callbacks
  def handle_call({:add_rover, rover_pid}, _from, state) do
    {:reply, :ok, do_add_rover(state, rover_pid)}
  end

  def handle_call({:move_rover, %Rover{}=rover_state}, _from, state) do
    {:reply, do_move_rover(state, rover_state), state}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  # Internal
  defp do_add_rover(%Plateau{}=p, rover_pid) do
    %Plateau{p | rovers: [rover_pid | p.rovers]}
  end

  defp run_turn_for_each_rover(rovers) do
    Enum.each(rovers, fn rover_pid ->
      Rover.execute_command(rover_pid)
    end)
  end

  defp do_move_rover(%Plateau{}=plateau, %Rover{}=s) do
    {s.x, s.y}
    |> new_position(s.d)
    |> verify_in_bounds(plateau)
  end

  defp new_position({x, y} , d) do
    case d do
      "N" -> {x, y + 1}
      "S" -> {x, y - 1}
      "E" -> {x + 1, y}
      "W" -> {x - 1, y}
    end
  end

  defp verify_in_bounds({x, y}, %Plateau{max_x: max_x, max_y: max_y}) do
    cond do
      x < 0     -> {:wall_collision, "W"}
      x > max_x -> {:wall_collision, "E"}
      y < 0     -> {:wall_collision, "S"}
      y > max_y -> {:wall_collision, "N"}
      true      -> {:ok, {x,y}}
    end
  end

end
