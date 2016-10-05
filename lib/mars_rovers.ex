defmodule MarsRovers do
  defmodule OutOfBoundsError do
    defexception message: "rover moved outside of plateau"
  end

  defmodule State do
    defstruct x: nil, y: nil, a: nil
  end

  def cardinal_to_angle(cardinal), do: %{"N" => 0, "E" => 90, "S" => 180, "W" => 270}[cardinal]
  def angle_to_cardinal(angle), do: %{0 => "N", 90 => "E", 180 => "S", 270 => "W"}[angle]

  def normalise_angle(angle) when angle < 0, do: normalise_angle(360+angle)
  def normalise_angle(angle), do: rem(angle, 360)

  def execute_commands({x, y, d}, commands, grid) do
    state = execute_commands(%State{ x: x, y: y, a: cardinal_to_angle(d)}, commands, grid)
    {state.x, state.y, angle_to_cardinal(state.a)}
  end

  def execute_commands(%State{}=state, [], _), do: state
  def execute_commands(%State{}=state, [command | commands], grid) do
    execute_command(state, command, grid)
    |> execute_commands(commands, grid)
  end

  def execute_command(%State{a: a}=state, "L", _) do
    %{state | a: normalise_angle(a - 90)}
  end

  def execute_command(%State{a: a}=state, "R", _) do
    %{state | a: normalise_angle(a + 90)}
  end

  def execute_command(%State{}=s, "M", grid) do
    case s.a do
      0   -> %State{s | y: s.y + 1}
      180 -> %State{s | y: s.y - 1}
      90  -> %State{s | x: s.x + 1}
      270 -> %State{s | x: s.x - 1}
    end
    |> verify_in_bounds(grid)
  end

  def verify_in_bounds(%State{x: x, y: y}=state, {max_x, max_y}) do
    if x in 0..max_x && y in 0..max_y do
      state
    else
      raise OutOfBoundsError
    end
  end
end
