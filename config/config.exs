import Config

if Mix.env() == :test do
  config :conduit, Conduit.Encoding, [
    {"json", ConduitNSQ.JsonEncoding}
  ]

  config :conduit_nsq, BrokerSpec.Broker,
    adapter: ConduitNSQ,
    producer_nsqds: [
      "127.0.0.1:12150",
      "127.0.0.1:13150"
    ],
    nsqds: [
      "127.0.0.1:12150",
      "127.0.0.1:13150",
      "127.0.0.1:14150"
    ],
    nsqlookupds: ["127.0.0.1:12161"],
    backoff_multiplier: 2_000
end
