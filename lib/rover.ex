defmodule MarsRovers.Rover do
  alias MarsRovers.Rover
  alias MarsRovers.Plateau

  defstruct x: nil, y: nil, d: nil, last_move_valid: true

  def execute_commands(%Rover{}=state, [], _), do: state
  def execute_commands(%Rover{}=state, [command | commands], %Plateau{}=plateau) do
      state
      |> execute_command(command, plateau)
      |> execute_commands(commands, plateau)
  end

  def execute_command(%Rover{d: d}=state, "L", _) do
    case d do
      "N" -> %Rover{state | d: "W"}
      "S" -> %Rover{state | d: "E"}
      "E" -> %Rover{state | d: "N"}
      "W" -> %Rover{state | d: "S"}
    end
  end

  def execute_command(%Rover{d: d}=state, "R", _) do
    case d do
      "N" -> %Rover{state | d: "E"}
      "S" -> %Rover{state | d: "W"}
      "E" -> %Rover{state | d: "S"}
      "W" -> %Rover{state | d: "N"}
    end
  end

  def execute_command(%Rover{}=s, "M", %Plateau{}=plateau) do
    case move_rover(s, plateau) do
      {:ok, {new_x, new_y}}  -> %Rover{ s | last_move_valid: true, x: new_x, y: new_y,}
      {:error, _}            -> %Rover{ s | last_move_valid: false}
    end
  end

  defp move_rover(%Rover{}=s, %Plateau{}=plateau) do
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
    if x in 0..max_x && y in 0..max_y do
      {:ok, {x,y}}
    else
      {:error, :out_of_bounds}
    end
  end
end
