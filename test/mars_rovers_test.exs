defmodule MarsRovers.Test do
  use ExUnit.Case
  alias MarsRovers.Rover
  alias MarsRovers.Setup
  doctest MarsRovers.Setup

  defmodule StraightLineCommander do
    def on_idle, do: ~w(M)
    def on_wall_collision(_), do: IO.puts "Collision"
  end

defmodule TestSetup do
  @doc "Start everything manually - can be used for testing"
  def setup({max_x, max_y}) do
    {:ok, _pid} = MarsRovers.Plateau.start_link([max_x: max_x, max_y: max_y])
    {:ok, _pid} = MarsRovers.EventManager.start_link
    :ok = GenEvent.add_handler(MarsRovers.EventManager, MarsRovers.PlateauVisualiserCLI, [])
  end
end

  test "Moving rover N works" do
    TestSetup.setup({5,5})
    assert %Rover{x: 0, y: 5, d: "N"} = Setup.deploy_rover(%Rover{x: 0, y: 0, d: "N", commander: StraightLineCommander}, 5)
  end

  test "Moving rover E works" do
    TestSetup.setup({5,5})
    assert %Rover{x: 5, y: 0, d: "E"} = Setup.deploy_rover(%Rover{x: 0, y: 0, d: "E", commander: StraightLineCommander}, 5)
  end

  test "Moving rover W works" do
    TestSetup.setup({5,5})
    assert %Rover{x: 0, y: 0, d: "W"} = Setup.deploy_rover(%Rover{x: 5, y: 0, d: "W", commander: StraightLineCommander}, 5)
  end

  test "Moving rover W when 1 from wall" do
    TestSetup.setup({5,5})
    assert %Rover{x: 0, y: 0, d: "W"} = Setup.deploy_rover(%Rover{x: 1, y: 0, d: "W", commander: StraightLineCommander}, 2)
  end

  test "executing first data set gives expected results" do
    defmodule TestCommander do
      def on_idle, do: ~w(L M L M L M L M M)
      def on_wall_collision(_), do: IO.puts "Collision"
    end
    TestSetup.setup({5,5})
    assert %Rover{x: 1, y: 3, d: "N"} = Setup.deploy_rover(%Rover{x: 1, y: 2, d: "N", commander: TestCommander}, 9)
  end

  test "executing second data set gives expected results" do
    defmodule TestCommander do
      def on_idle, do: ~w(M M R M M R M R R M)
      def on_wall_collision(_), do: []
    end
    TestSetup.setup({5,5})
    assert %Rover{x: 5, y: 1, d: "E"} = Setup.deploy_rover(%Rover{x: 3, y: 3, d: "E", commander: TestCommander}, 10)
  end

  test "error is raised when rover moves outside of plateau" do
    defmodule TestCommander do
      def on_idle, do: ~w(M M)
      def on_wall_collision(w), do: ~w(R)
    end
    TestSetup.setup({5,5})
    assert %Rover{x: 0, y: 1, d: "W", last_move_valid: false} = Setup.deploy_rover(%Rover{x: 1, y: 1, d: "W", commander: TestCommander}, 2)
  end

  test "turns on hitting wall" do
    defmodule TestCommander do
      def on_idle, do: ~w(M)
      def on_wall_collision(_), do: ~w(R)
    end
    TestSetup.setup({10,10})
    assert %Rover{x: 1, y: 10, d: "E"} = Setup.deploy_rover(%Rover{x: 5, y: 5, d: "W", commander: TestCommander}, 15)
  end

  test "executing multiple rovers on a plateau" do
    defmodule TestCommander1 do
      def on_idle, do: ~w(L M L M L M L M M)
      def on_wall_collision(_), do: []
    end
    defmodule TestCommander2 do
      def on_idle, do: ~w(M M R M M R M R R M)
      def on_wall_collision(_), do: []
    end
    rovers = [
      %Rover{x: 1, y: 2, d: "N", commander: TestCommander1},
      %Rover{x: 3, y: 3, d: "E", commander: TestCommander2}
    ]
    TestSetup.setup({5,5})
    [rover1, rover2] = Setup.deploy_rovers( rovers, 10)
    assert %Rover{x: 1, y: 3, d: "W"} = rover1
    assert %Rover{x: 5, y: 1, d: "E"} = rover2
  end

  @tag :skip
  test "executing multiple rovers with different behaviours" do
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
    TestSetup.setup({40,40})
    [rover1, rover2] = Setup.deploy_rovers( rovers, 1000)
    assert %Rover{x: 1, y: 3, d: "W"} = rover1
    assert %Rover{x: 5, y: 1, d: "E"} = rover2
  end

  @tag :skip
  test "executing many rovers on plateau" do
    grid_size = 40
    defmodule RandomCommander do
      def on_idle, do: [Enum.random(~w(L R M M M M M M M))]
      def on_wall_collision(_), do: ~w(R)
    end
    TestSetup.setup({grid_size, grid_size})
    1..10
    |> Enum.map( fn(_) -> %Rover{x: :rand.uniform(grid_size), y: :rand.uniform(grid_size), d: Enum.random(~w(N S E W)), commander: RandomCommander} end)
    |> Setup.deploy_rovers(100)
  end
end
