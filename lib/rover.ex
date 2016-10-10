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
    case Plateau.move_rover(plateau, s) do
      {:ok, {new_x, new_y}}  -> %Rover{ s | last_move_valid: true, x: new_x, y: new_y}
      {:error, _}            -> %Rover{ s | last_move_valid: false}
    end
  end
end
