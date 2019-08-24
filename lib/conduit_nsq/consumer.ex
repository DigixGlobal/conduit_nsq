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

  def child_spec([broker, name, sub_opts, opts]) do
    topic = Keyword.fetch!(sub_opts, :topic)
    channel = Keyword.fetch!(sub_opts, :channel)

    timeout = Application.get_env(:conduit_nsq, :process_timeout, 60_000)

    handler = fn msg, _body ->
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

    config =
      opts
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
    {Module.concat(broker, Consumer), name}
  end
end
