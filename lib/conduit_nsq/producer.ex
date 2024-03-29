defmodule ConduitNSQ.Producer do
  @moduledoc """
  Starts producer for each topic
  """

  use GenServer

  alias ConduitNSQ.MessagePublisher

  defmodule State do
    defstruct [:broker, :name, :pid]
  end

  def start_link(broker, name, sub_opts, opts) do
    GenServer.start_link(__MODULE__, [broker, name, sub_opts, opts])
  end

  def child_spec([broker, name, sub_opts, opts]) do
    %{
      id: name(broker, name),
      start: {
        __MODULE__,
        :start_link,
        [broker, name, sub_opts, opts]
      },
      type: :worker
    }
  end

  @impl true
  def init([broker, name, sub_opts, opts]) do
    nsqds = Keyword.fetch!(opts, :producer_nsqds)

    config =
      opts
      |> Enum.into(%{})
      |> Map.merge(%{})
      |> (&struct(NSQ.Config, &1)).()
      |> Map.put(:nsqlookupds, [])
      |> Map.put(:nsqds, nsqds)

    {:ok, pid} =
      NSQ.Producer.Supervisor.start_link(
        name,
        config
      )

    {:ok, %State{broker: broker, name: name, pid: pid}}
  end

  @impl true
  def handle_call(
        {:publish, topic, message, timeout},
        _from,
        %State{name: name, pid: pid} = state
      ) do
    if topic == name do
      pid
      |> MessagePublisher.publish_message(message)
      |> Honeydew.yield(timeout)
      |> case do
        {:ok, :sent} ->
          {:reply, :sent, state}
      end
    else
      {:reply, :ignored, state}
    end
  end

  def publish(pid, topic, message, timeout \\ :infinity) do
    GenServer.call(pid, {:publish, topic, message, timeout}, timeout)
  end

  defp name(broker, name) do
    {Module.concat(broker, Producer), name}
  end
end
