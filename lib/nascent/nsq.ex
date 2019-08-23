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
    request_opts = Keyword.merge(config, request_opts(opts))

    topic = Keyword.fetch!(opts, :topic)

    ProducerGroup.publish(broker, topic, body)
  end

  defp request_opts(opts),
    do: Keyword.take(opts, [:region, :base_backoff_in_ms, :max_backoff_in_ms, :max_attempts])
end
