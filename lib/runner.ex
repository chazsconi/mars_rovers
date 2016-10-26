defmodule MarsRovers.Runner do
  alias MarsRovers.Rover
  alias MarsRovers.Setup

  def start_link(opts) do
    pid = spawn fn -> MarsRovers.Runner.run_multiple(opts[:delay]) end
    {:ok, pid}
  end

  def run_multiple(delay) do
    defmodule WallCommanderL do
      def on_idle, do: ~w(M)
      def on_wall_collision(_), do: ~w[L]
    end
    defmodule WallCommanderR do
      def on_idle, do: ~w(M)
      def on_wall_collision(_), do: ~w(R)
    end
    defmodule BounceCommander do
      def on_idle, do: ~w(M)
      def on_wall_collision(_), do: ~w(R R)
    end
    defmodule RandomCommander do
      def on_idle, do: [Enum.random(~w(L R M M M M M M M M M M M M M M M M M M M M M M M M M))]
      def on_wall_collision(_), do: ~w(R)
    end
    defmodule CircleCommander do
      def on_idle, do: List.duplicate("M", 50) ++ ["R"]
      def on_wall_collision(_), do: ~w(R)
    end
    defmodule DiagonalCommander do
      def on_idle, do: List.duplicate("M", 50) ++ ["R"] ++ List.duplicate("M", 50) ++ ["L"]
      def on_wall_collision(_), do: ~w(R)
    end
    rovers = [
      %Rover{id: 1, x: 10, y: 2, d: "N", commander: WallCommanderL},
      %Rover{id: 2, x: 3, y: 3, d: "E", commander: WallCommanderR},
      %Rover{id: 3, x: 8, y: 8, d: "W", commander: BounceCommander},
      %Rover{id: 4, x: 5, y: 5, d: "W", commander: RandomCommander},
      %Rover{id: 5, x: 100, y: 100, d: "W", commander: CircleCommander},
      %Rover{id: 6, x: 100, y: 100, d: "W", commander: DiagonalCommander}
    ]

    Setup.deploy_rovers(rovers, -1, delay)
  end
end
