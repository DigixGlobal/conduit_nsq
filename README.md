# ConduitNSQ

[![CircleCI](https://circleci.com/gh/DigixGlobal/conduit_nsq/tree/master.svg?style=svg)](https://circleci.com/gh/DigixGlobal/conduit_nsq/tree/master)

A (NSQ)[https://nsq.io/] adapter for [conduit](https://github.com/conduitframework/conduit).


## Installation

The package can be installed by adding `conduit_nsq` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:conduit_nsq, "~> 0.1.0"}]
end
```

## Configuring the Adapter

This library uses (elixir_nsq)[https://github.com/wistia/elixir_nsq] to
connect to the message queue.


Given a broker (`MyApp.Broker`), you can use this library as the adapter:

``` elixir
config :conduit_nsq, MyApp.Broker,
  adapter: ConduitNSQ

```


```elixir
config :conduit_nsq, MyApp.Broker,
  nsqds: ["127.0.0.1:12150", "127.0.0.1:13150", "127.0.0.1:14150" ],
  nsqlookupds: ["127.0.0.1:12161"],
  backoff_multiplier: 2_000
```

