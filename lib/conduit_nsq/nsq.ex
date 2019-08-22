defmodule ConduitNSQ.NSQ do
  @moduledoc """
  Interface between ConduitNSQ and NSQ
  """
  require Logger

  import Conduit.Message
  alias Conduit.Message
  alias Jason

  alias ConduitNSQ.{ProducerGroup}

  @doc """
  Converts a Conduit message to an SQS message and publishes it
  """
  def publish(broker, %Message{body: body}, config, opts) do
    topic = Keyword.fetch!(opts, :topic)

    ProducerGroup.publish(broker, topic, body)
  end

  @doc """
  Converts raw messages into `Conduit.Message`
  """
  def to_message(message, queue) do
    %Message{}
    |> put_source(queue)
    |> put_body(message)
  end
end
