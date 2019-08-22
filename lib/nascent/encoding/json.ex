defmodule Nascent.Encoding.Json do
  @moduledoc """
  Simple JSON encoding for messages using `Jason`
  """

  use Conduit.Encoding

  alias Jason

  def encode(message, _opts) do
    put_body(message, Jason.encode!(message.body))
  end
  def decode(message, _opts) do
    put_body(message, Jason.decode!(message.body))
  end
end
