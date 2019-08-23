defmodule ConduitNSQ.Consumer do
  @moduledoc """
  Starts consumers for each topic
  """

  use Supervisor

  alias Conduit.Message
  alias Jason
  alias Honeydew
  alias NSQ

  alias ConduitNSQ.MessageProcessor

  def start_link(broker, name, sub_opts, opts) do
    Supervisor.start_link(
      __MODULE__,
      [broker, name, sub_opts, opts],
      name: name(broker, name)
    )
  end

  def child_spec([broker, name, sub_opts, _opts]) do
    base_opts = Application.fetch_env!(:conduit_nsq, ConduitNSQ.Config)

    topic = Keyword.fetch!(sub_opts, :topic)
    channel = Keyword.get(sub_opts, :channel, "")

    timeout = Application.get_env(:conduit_nsq, :process_timeout, 60_000)

    handler = fn msg, body ->
      message = %Message{body: msg}

      broker
      |> MessageProcessor.process_message(name, message)
      |> Honeydew.yield(timeout)
      |> case do
           nil ->
             :req

           {:ok, reply} ->
             reply
         end
    end

    config = base_opts
    |> Enum.into(%{})
    |> Map.merge(%{message_handler: handler})
    |> (&struct(NSQ.Config, &1)).()

    %{
      id: name(broker, name),
      start: {
        NSQ.Consumer,
        :start_link,
        [
          topic,
          channel,
          config
        ]
      },
      type: :worker
    }
  end

  @impl true
  def init(_opts) do
    {:ok, nil}
  end

  defp name(broker, name) do
    {Module.concat(broker, Adapter.Consumer), name}
  end
end
