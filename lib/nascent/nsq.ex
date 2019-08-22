defmodule Nascent.NSQ do
  @moduledoc """
  Interface between Nascent and NSQ
  """
  require Logger

  alias Conduit.Message
  alias Jason

  @doc """
  Converts a Conduit message to an SQS message and publishes it
  """
  def publish(%Message{body: body} = message, config, opts) do
    request_opts = Keyword.merge(config, request_opts(opts))

    topic = Keyword.fetch!(opts, :topic)

    {:ok, p1} =
      NSQ.Producer.Supervisor.start_link(
        topic,
        %NSQ.Config{
          nsqds: ["127.0.0.1:12150", "127.0.0.1:13150", "127.0.0.1:14150"]
        }
      )

    NSQ.Producer.pub(p1, Jason.encode!(message.body))
  end

  defp request_opts(opts),
    do: Keyword.take(opts, [:region, :base_backoff_in_ms, :max_backoff_in_ms, :max_attempts])
end
