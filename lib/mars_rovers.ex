defmodule MarsRovers do
  use Application

  def start(_type, args) do
    import Supervisor.Spec, warn: false
    {max_x, max_y} = Application.get_env(:mars_rovers, :plateau_size)

    children = [
      worker(MarsRovers.EventManager, []),
      worker(MarsRovers.Plateau, [[max_x: max_x, max_y: max_y]])
    ]

    opts = [strategy: :one_for_one, name: MarsRovers.Supervisor]
    {:ok, supervisor_pid} = Supervisor.start_link(children, opts)

    # The CLI visualiser can be enabled by uncommenting this line
    # :ok = GenEvent.add_handler(MarsRovers.EventManager, MarsRovers.PlateauVisualiserCLI, [])
    {:ok, supervisor_pid}
  end
end
