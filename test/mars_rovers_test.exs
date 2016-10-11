defmodule MarsRoversTest do
  use ExUnit.Case
  alias MarsRovers.Rover
  doctest MarsRovers

  test "executing first data set gives expected results" do
    commands = ~w(L M L M L M L M M)

    assert MarsRovers.deploy_rover(%Rover{x: 1, y: 2, d: "N"}, commands, {5, 5}) == %Rover{x: 1, y: 3, d: "N"}
  end

  test "executing second data set gives expected results" do
    commands = ~w(M M R M M R M R R M)

    assert MarsRovers.deploy_rover(%Rover{x: 3, y: 3, d: "E"}, commands, {5, 5}) == %Rover{x: 5, y: 1, d: "E"}
  end

  test "error is raised when rover moves outside of plateau" do
    assert MarsRovers.deploy_rover(%Rover{x: 1, y: 1, d: "W"}, ~w(M M), {5, 5}) == %Rover{x: 0, y: 1, d: "W", last_move_valid: false}
  end

  test "executing multiple rovers on a plateau" do
    instructions = [
      {%Rover{x: 1, y: 2, d: "N"}, ~w(L M L M L M L M M)},
      {%Rover{x: 3, y: 3, d: "E"}, ~w(M M R M M R M R R M)}
    ]
    assert MarsRovers.deploy_rovers({5, 5}, instructions) == [%Rover{x: 1, y: 3, d: "N"}, %Rover{x: 5, y: 1, d: "E"}]
  end
end
