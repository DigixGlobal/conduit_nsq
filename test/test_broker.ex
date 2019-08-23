defmodule ConduitNSQ.TestBroker do
  use Conduit.Broker, otp_app: :conduit_nsq

  configure do
    queue("my-topic")
    queue("other-topic")
  end

  incoming ConduitNSQ do
    subscribe(
      :basic_topic,
      BasicTopic,
      topic: "my-topic"
    )

    subscribe(
      :basic_topic_and_channel,
      BasicTopic,
      topic: "my-topic",
      channel: "my-channel"
    )
  end

  outgoing do
    pipe_through([:out_tracking, :serialize])

    publish(:my_publisher,
      topic: "my-topic"
    )

    publish(:other_publisher,
      topic: "other-topic"
    )
  end
end
