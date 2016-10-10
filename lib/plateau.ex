defmodule MarsRovers.Plateau do
  alias MarsRovers.Plateau
  alias MarsRovers.Rover
  defstruct max_x: nil, max_y: nil, rovers: []

  @doc "Tries to move a rover on the plateau.  Returns {:ok, new_position} or {:ok, error}"
  def move_rover(%Plateau{}=plateau, %Rover{}=s) do
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
