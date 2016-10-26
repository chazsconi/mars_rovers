defmodule MarsRovers.EventManager do
  use GenEvent

  def start_link do
    {:ok, _pid} = GenEvent.start_link(name: __MODULE__)
  end
end
