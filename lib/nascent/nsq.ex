defmodule Nascent.NSQ do
  @moduledoc """
  Interface between Nascent and NSQ
  """
  require Logger

  alias Conduit.Message
  alias Jason

  alias Nascent.{ProducerGroup}

  @doc """
  Converts a Conduit message to an SQS message and publishes it
  """
  def publish(broker, %Message{body: body}, config, opts) do
    IO.inspect(config)
    topic = Keyword.fetch!(opts, :topic)

    ProducerGroup.publish(broker, topic, body)
  end

end
