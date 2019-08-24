defmodule BrokerSpec do
  use ESpec
  use Quixir

  alias Conduit.Message

  defmodule Subscriber do
    use Conduit.Subscriber

    def process(message, _) do
      send(BrokerSpec, {:process, message})

      message
    end
  end

  defmodule Broker do
    use Conduit.Broker, otp_app: :conduit_nsq

    configure do
      queue "subscription"
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

      publish :sub,
        topic: "subscription",
        channel: "channel"
    end

    incoming BrokerSpec do
      pipe_through [:input]

      subscribe :sub, Subscriber,
        topic: "subscription",
        channel: "channel"
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
        ptest([original: choose(from: [list(of: string), string])], [repeat_for: 10]) do
          {:ok, :sent} = %Message{}
          |> Message.put_body(original)
          |> Broker.publish(:sub)

          assert_receive {:process, sent_message}, 5_000

          assert sent_message.body == original
        end
    end
  end
end
