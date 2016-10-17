defmodule MarsRovers.Test do
  use ExUnit.Case
  alias MarsRovers.Rover
  doctest MarsRovers

  test "executing first data set gives expected results" do
    defmodule TestCommander, do: def on_idle, do: ~w(L M L M L M L M M)
    assert %Rover{x: 1, y: 3, d: "N"} = MarsRovers.deploy_rover(%Rover{x: 1, y: 2, d: "N", commander: TestCommander}, {5, 5}, 9)
  end

  test "executing second data set gives expected results" do
    defmodule TestCommander, do: def on_idle, do: ~w(M M R M M R M R R M)
    assert %Rover{x: 5, y: 1, d: "E"} = MarsRovers.deploy_rover(%Rover{x: 3, y: 3, d: "E", commander: TestCommander}, {5, 5}, 10)
  end

  test "error is raised when rover moves outside of plateau" do
    defmodule TestCommander, do: def on_idle, do: ~w(M M)
    assert %Rover{x: 0, y: 1, d: "W", last_move_valid: false} = MarsRovers.deploy_rover(%Rover{x: 1, y: 1, d: "W", commander: TestCommander}, {5, 5}, 2)
  end

  test "executing multiple rovers on a plateau" do
    defmodule TestCommander1, do: def on_idle, do: ~w(L M L M L M L M M)
    defmodule TestCommander2, do: def on_idle, do: ~w(M M R M M R M R R M)
    rovers = [
      %Rover{x: 1, y: 2, d: "N", commander: TestCommander1},
      %Rover{x: 3, y: 3, d: "E", commander: TestCommander2}
    ]
    [rover1, rover2] = MarsRovers.deploy_rovers( rovers, {5, 5}, 10)
    assert %Rover{x: 1, y: 3, d: "W"} = rover1
    assert %Rover{x: 5, y: 1, d: "E"} = rover2
  end

  @tag :skip
  test "executing many rovers on plateau" do
    grid_size = 40
    defmodule RandomCommander, do: def on_idle, do: [Enum.random(~w(L R M M M M M M M))]
    1..10
    |> Enum.map( fn(n) -> %Rover{x: :rand.uniform(grid_size), y: :rand.uniform(grid_size), d: Enum.random(~w(N S E W)), commander: RandomCommander} end)
    |> MarsRovers.deploy_rovers({grid_size, grid_size}, 1000)
  end
end
