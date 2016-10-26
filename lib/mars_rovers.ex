defmodule MarsRovers do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(MarsRovers.EventManager, []),
      worker(MarsRovers.Plateau, [[max_x: 40, max_y: 40]])
    ]

    opts = [strategy: :one_for_one, name: MarsRovers.Supervisor]
    {:ok, supervisor_pid} = Supervisor.start_link(children, opts)

    :ok = GenEvent.add_handler(MarsRovers.EventManager, MarsRovers.PlateauVisualiserCLI, [])
    {:ok, supervisor_pid}
  end
end
