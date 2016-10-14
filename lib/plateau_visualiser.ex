defmodule MarsRovers.PlateauVisualiserCLI do
  use GenEvent
  alias MarsRovers.{Rover, Plateau}
  import IO.ANSI, only: [clear: 0, home: 0]

  def handle_event(:rover_moved, state) do
    visualise
    {:ok, state}
  end

  def visualise do
    IO.puts [clear, home, to_string(Plateau.visual_state)]
  end

  defimpl String.Chars, for: MarsRovers.Plateau.VisualState do
    def to_string(plateau) do
      {max_x, max_y} = plateau.size
      for y <- max_y..0 do
        for x <- 0..max_x do
          cell_to_string(plateau.cells[{x, y}])
        end
        |> Enum.join(" ")
      end
      |> Enum.join("\n")
    end

    defp cell_to_string(%Rover{} = position) do
      case position.d do
        "N" -> "^"
        "S" -> "v"
        "E" -> ">"
        "W" -> "<"
      end
    end
    defp cell_to_string(_), do: "-"
  end
end
