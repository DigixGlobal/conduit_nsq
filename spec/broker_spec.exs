defmodule BrokerSpec do
  use ESpec
  use Quixir

  alias Conduit.Message

  defmodule MySubscriber do
    use Conduit.Subscriber

    def process(message, _) do
      send(BrokerSpec, {:my_process, message})

      message
    end
  end

  defmodule ThatSubscriber do
    use Conduit.Subscriber

    def process(message, _) do
      send(BrokerSpec, {:that_process, message})

      message
    end
  end

  defmodule OtherSubscriber do
    use Conduit.Subscriber

    def process(message, _) do
      send(BrokerSpec, {:other_process, message})

      message
    end
  end

  defmodule EphermalSubscriber do
    use Conduit.Subscriber

    def process(message, _) do
      send(BrokerSpec, {:ephermal_process, message})

      message
    end
  end

  defmodule Broker do
    use Conduit.Broker, otp_app: :conduit_nsq

    configure do
      queue("my-topic")
      queue("other-topic")
      queue("ghost-topic", ephemeral: true)
    end

    pipeline :input do
      plug(Conduit.Plug.Decode, content_encoding: "json")
      plug(Conduit.Plug.Unwrap)
    end

    pipeline :output do
      plug(Conduit.Plug.Wrap)
      plug(Conduit.Plug.Encode, content_encoding: "json")
    end

    outgoing do
      pipe_through [:output]

      publish :my_sub,
        topic: "my-topic"
      publish :other_sub,
        topic: "other-topic"
    end

    incoming BrokerSpec do
      pipe_through [:input]

      subscribe :my_sub, MySubscriber,
        topic: "my-topic",
        channel: "channel"

      subscribe :that_sub, ThatSubscriber,
        topic: "my-topic",
        channel: "other-channel"

      subscribe :other_sub, OtherSubscriber,
        topic: "other-topic",
        channel: "channel"

      subscribe :ephermal_sub, EphermalSubscriber,
        topic: "ghost-topic",
        channel: "channel",
        ephemeral: true
    end
  end

  describe "Broker" do
    before_all do
      Broker.start_link()
    end

    before do
      Process.register(self(), __MODULE__)
    end

    it "should publish and receive messages" do
        ptest([original: choose(from: [list(of: string()), string()])], [repeat_for: 3]) do
          {:ok, :sent} = %Message{}
          |> Message.put_body(original)
          |> Broker.publish(:my_sub)

          assert_receive {:my_process, sent_message}, 7_000

          assert sent_message.body == original
        end
    end

    it "subscribers should receive correct topic messages" do
      ptest(
        [
          first: choose(from: [list(of: string()), string()]),
          second: choose(from: [list(of: string()), string()]),
        ],
        [repeat_for: 3]) do
          {:ok, :sent} = %Message{}
          |> Message.put_body(first)
          |> Broker.publish(:my_sub)

          assert_receive {:my_process, first_message}, 7_000
          refute_receive :other_process

          assert %Message{body: ^first} = first_message

          {:ok, :sent} = %Message{}
          |> Message.put_body(second)
          |> Broker.publish(:other_sub)

          assert_receive {:other_process, second_message}, 7_000
          refute_receive :my_process

          assert %Message{body: ^second} = second_message
        end
    end

    it "all subscribers should receive messages from a topic" do
      ptest(
        [original: choose(from: [list(of: string()), string()])],
        [repeat_for: 3]
      ) do
          {:ok, :sent} = %Message{}
          |> Message.put_body(original)
          |> Broker.publish(:my_sub)

          assert_receive {:my_process, _}, 7_000
          assert_receive {:that_process, _}, 7_000
        end
    end
  end
end
