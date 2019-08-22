defmodule Nascent.Consumer do
  @moduledoc """
  Starts consumers for each topic
  """
  use Supervisor

  alias Conduit.Message
  alias Jason
  alias NSQ

  def child_spec([broker, name, sub_opts, opts]) do
    topic = Keyword.fetch!(sub_opts, :topic)
    channel = Keyword.get(sub_opts, :channel, "")

    %{
      id: name(broker, name),
      start: {
        NSQ.Consumer,
        :start_link,
        [
          topic,
          channel,
          %NSQ.Config{
            nsqds: [
              "127.0.0.1:12150",
              "127.0.0.1:13150",
              "127.0.0.1:14150"
            ],
            nsqlookupds: ["127.0.0.1:12161"],
            message_handler: fn msg, body ->
              message = %Message{body: msg}

              case broker.receives(name, message) do
                %Message{status: :ack} ->
                  :ok

                %Message{status: :nack} ->
                  :req
              end

            end
          }
        ]
      },
      type: :worker
    }
  end

  @doc false
  def start_link(broker, name, sub_opts, opts) do
    Supervisor.start_link(__MODULE__, [broker, name, sub_opts, opts])
  end

  def name(broker, name) do
    {Module.concat(broker, Adapter.Consumer), name}
  end
end
