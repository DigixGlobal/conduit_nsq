defmodule ConduitNSQ.NSQ do
  @moduledoc """
  Interface between ConduitNSQ and NSQ
  """
  require Logger

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
end
