defmodule Example do
  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [Example.Bot],
      strategy: :one_for_one
    )
  end
end
