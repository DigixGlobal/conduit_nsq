defmodule Nascent.MessagePublisher do
  @moduledoc """
  Publishes messages in a queue
  """

  use GenServer

  @queue_name :message_publisher

  defmodule Worker do
    @behaviour Honeydew.Worker

    alias NSQ.Producer, as: Client

    def run(pid, message) do
      case Client.pub(pid, message) do
        {:ok, "OK"} ->
          :sent
        error ->
          error
      end

    end
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(_arg) do
    @queue_name
    |> Honeydew.start_queue(
      failure_mode: {
        Honeydew.FailureMode.ExponentialRetry,
        times: 3,
        base: 2
      }
    )

    @queue_name
    |> Honeydew.start_workers(Worker, num: 5)

    {:ok, nil}
  end

  def publish_message(pid, message) do
    Honeydew.async(
      {:run, [pid, message]},
      @queue_name,
      reply: true
    )
  end
end
