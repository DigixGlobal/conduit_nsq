import Config

config :conduit_nsq,
  publisher_workers: 3,
  processor_workers: 10,
  publish_timeout: 5000,
  process_timeout: 5000

if Mix.env() == :test do
  config :conduit, Conduit.Encoding, [
    {"json", ConduitNSQ.Encoding.Json}
  ]

  config :conduit_nsq, ConduitNSQIntegrationTest.Broker, adapter: ConduitNSQ

  config :conduit_nsq, BrokerSpec.Broker, adapter: ConduitNSQ

  config :conduit_nsq, ConduitNSQ.Config,
    nsqds: [
      "127.0.0.1:12150",
      "127.0.0.1:13150",
      "127.0.0.1:14150"
    ],
    nsqlookupds: ["127.0.0.1:12161"],
    backoff_multiplier: 2_000
end
