defmodule Nascent.Consumer do
  @moduledoc """
  Starts consumers for each topic
  """

  use Supervisor

  alias Conduit.Message
  alias Jason
  alias Honeydew
  alias NSQ

  alias Nascent.MessageProcessor

  def start_link(broker, name, sub_opts, opts) do
    Supervisor.start_link(
      __MODULE__,
      [broker, name, sub_opts, opts],
      name: name(broker, name)
    )
  end

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

              timeout =
                body
                |> Map.fetch!(:config)
                |> Map.fetch!(:msg_timeout)

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
          }
        ]
      },
      type: :worker
    }
  end

  defp name(broker, name) do
    {Module.concat(broker, Adapter.Consumer), name}
  end
end
