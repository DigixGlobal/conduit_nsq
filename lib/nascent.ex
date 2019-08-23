defmodule Nascent do
  @moduledoc """
  Implements the Conduit adapter interface for NSQ
  """

  require Logger

  use Conduit.Adapter
  use Supervisor

  alias Nascent.NSQ

  def child_spec([broker, _, _, _] = args) do
    %{
      id: name(broker),
      start: {__MODULE__, :start_link, args},
      type: :supervisor
    }
  end

  @doc """
  Implents Conduit.Adapter.start_link/4 callback
  """
  @impl true
  def start_link(broker, topology, subscribers, opts) do
    # OptionValidator.validate!(topology, subscribers, opts)

    Supervisor.start_link(
      __MODULE__,
      [broker, topology, subscribers, opts],
      name: name(broker)
    )
  end

  @doc false
  @impl true
  def init([broker, topology, subscribers, opts]) do
    import Supervisor.Spec

    Logger.info("NSQ Adapter started!")

    children = [
      worker(Nascent.MessageProcessor, [opts]),
      worker(Nascent.MessagePublisher, [opts]),
      {Nascent.ProducerGroup, [broker, topology, opts]},
      {Nascent.ConsumerGroup, [broker, subscribers, opts]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Implents Conduit.Adapter.publish/3 callback
  """
  @impl true
  def publish(broker, message, config, opts) do
    NSQ.publish(broker, message, config, opts)
  end

  defp name(broker) do
    Module.concat(broker, Adapter)
  end
end
