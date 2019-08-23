defmodule Nascent.MessageProcessor do
  @moduledoc """
  Handles messages in a queue
  """

  use GenServer

  @queue_name :message_processor

  defmodule Worker do
    @behaviour Honeydew.Worker

    alias Conduit.Message

    def run(broker, name, message) do
      case broker.receives(name, message) do
        %Message{status: :ack} ->
          :ok

        %Message{status: :nack} ->
          :req
      end
    end
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    workers = Keyword.get(opts, :processor_workers, 10)

    @queue_name
    |> Honeydew.start_queue(
      failure_mode: {
        Honeydew.FailureMode.ExponentialRetry,
        times: 3,
        base: 2
      }
    )

    @queue_name
    |> Honeydew.start_workers(
      Worker,
      num: workers
    )

    {:ok, nil}
  end

  def process_message(broker, name, message) do
    Honeydew.async(
      {:run, [broker, name, message]},
      @queue_name,
      reply: true
    )
  end
end
