defmodule Nascent.Producer do
  @moduledoc """
  Starts producer for each topic
  """

  use Supervisor

  def start_link(broker, name, sub_opts, opts) do
    Supervisor.start_link(
      NSQ.Producer,
      [
        name,
        %NSQ.Config{
          nsqds: [
            "127.0.0.1:12150",
            "127.0.0.1:13150",
            "127.0.0.1:14150"
          ],
          nsqlookupds: ["127.0.0.1:12161"]
        }
      ],
      name: process_name(broker, name)
    )
  end

  def child_spec([broker, name, sub_opts, opts]) do
    %{
      id: name(broker, name),
      start: {
        __MODULE__,
        :start_link,
        [broker, name, sub_opts, opts]
      },
      type: :worker
    }
  end

  defp name(broker, name) do
    {Module.concat(broker, Adapter.Producer), name}
  end

  defp process_name(broker, name) do
    Module.concat(
      Module.concat(broker, Adapter.Producer),
      name
    )
  end
end
