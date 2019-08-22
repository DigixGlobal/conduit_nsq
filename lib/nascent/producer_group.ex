defmodule Nascent.ProducerGroup do
  @moduledoc """
  Manages producers
  """

  use Supervisor

  def start_link(broker, subscribers, opts) do
    Supervisor.start_link(
      __MODULE__,
      [broker, subscribers, opts],
      name: name(broker)
    )
  end

  def child_spec([broker, _, _] = args) do
    %{
      id: name(broker),
      start: {__MODULE__, :start_link, args},
      type: :supervisor
    }
  end

  @impl true
  def init([broker, topology, opts]) do
    children =
      topology
      |> Enum.filter(&(elem(&1, 0) == :queue))
      |> Enum.map(fn {:queue, name, sub_opts} ->
        {Nascent.Producer, [broker, name, sub_opts, opts]}
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp name(broker) do
    Module.concat(broker, Adapter.ProducerGroup)
  end
end
