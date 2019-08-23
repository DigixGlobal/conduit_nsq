defmodule Nascent.Producer do
  @moduledoc """
  Starts producer for each topic
  """

  use GenServer

  alias Nascent.MessagePublisher

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
    base_opts = Application.fetch_env!(:nascent, Nascent.Config)

    config = base_opts
    |> Enum.into(%{})
    |> Map.merge(%{})
    |> (&struct(NSQ.Config, &1)).()

    {:ok, pid} = NSQ.Producer.Supervisor.start_link(name, config)

    {:ok, %State{broker: broker, name: name, pid: pid}}
  end

  @impl true
  def handle_call({:publish, topic, message}, _from, %State{name: name, pid: pid} = state) do
    if topic == name  do
      pid
      |> MessagePublisher.publish_message(message)
      |> Honeydew.yield(60_000)
      |> case do
           {:ok, :sent} ->
             {:reply, :sent, state}
         end
    else
      {:reply, :ignored, state}
    end
  end

  def publish(pid, topic, message, timeout \\ 60_000) do
    GenServer.call(pid, {:publish, topic, message}, timeout)
  end

  defp name(broker, name) do
    {Module.concat(broker, Adapter.Producer), name}
  end
end
