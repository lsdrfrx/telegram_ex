defmodule Example do
  def start(_type, _args) do
    Supervisor.start_link(
      [Example.Bot],
      strategy: :one_for_one
    )
  end
end
