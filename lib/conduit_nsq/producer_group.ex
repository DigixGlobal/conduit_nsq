defmodule ConduitNSQ.ProducerGroup do
  @moduledoc """
  Manages producers
  """

  use Supervisor

  alias ConduitNSQ.Producer

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
      |> Enum.filter(&match?({:queue, _, _}, &1))
      |> Enum.map(fn {:queue, name, sub_opts} ->
        {Producer, [broker, name, sub_opts, opts]}
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end

  def producers(broker) do
    broker
    |> name()
    |> Supervisor.which_children()
    |> Enum.map(&elem(&1, 1))
  end

  def publish(broker, topic, message) do
    timeout = Application.get_env(:conduit_nsq, :publish_timeout, 60_000)

    broker
    |> producers()
    |> Enum.reduce_while(:unsent, fn pid, _acc ->
      case Producer.publish(pid, topic, message, timeout) do
        :sent ->
          {:halt, :sent}

        :ignored ->
          {:cont, :ignored}
      end
    end)
    |> case do
      :sent ->
        {:ok, :sent}

      :ignored ->
        {:error, :ignored}

      :unsent ->
        {:error, :unsent}
    end
  end

  defp name(broker) do
    Module.concat(broker, Adapter.ProducerGroup)
  end
end
