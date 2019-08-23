defmodule ConduitNSQ.Message do
  @moduledoc """
  Converts a batch of NSQ messages to Conduit messages
  """

  import Conduit.Message
  alias Conduit.Message

  def to_conduit_message(message, queue) do
    %Message{}
    |> put_source(queue)
    |> put_body(message)
  end
end
