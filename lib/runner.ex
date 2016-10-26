defmodule MarsRovers.Runner do
  alias MarsRovers.Rover
  alias MarsRovers.Setup

  def run_multiple do
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
      def on_idle, do: [Enum.random(~w(L R M M M M M M M))]
      def on_wall_collision(_), do: ~w(R)
    end
    rovers = [
      %Rover{x: 10, y: 2, d: "N", commander: WallCommanderL},
      %Rover{x: 3, y: 3, d: "E", commander: WallCommanderR},
      %Rover{x: 8, y: 8, d: "W", commander: BounceCommander},
      %Rover{x: 5, y: 5, d: "W", commander: RandomCommander}
    ]
    [_rover1, _rover2] = Setup.deploy_rovers(rovers, 1000)
  end
end
