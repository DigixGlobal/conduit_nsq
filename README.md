# ConduitNSQ

[![CircleCI](https://circleci.com/gh/DigixGlobal/conduit_nsq/tree/master.svg?style=svg)](https://circleci.com/gh/DigixGlobal/conduit_nsq/tree/master)

A (NSQ)[https://nsq.io/] adapter for [conduit](https://github.com/conduitframework/conduit).

*CAVEAT:* This adapter library is not mature so take precaution when
using it for production. This library also may not be as lightweight,
eficient, thoughtout. As an example, this library uses
(honeydew)[https://github.com/koudelka/honeydew] as a worker pool to
throttle sending and receiving messages instead of the builtin
`GenStage`.

## Installation

The package can be installed by adding `conduit_nsq` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:conduit_nsq, "~> 0.1.0"}]
end
```

Once you created your own `MyApp.Broker`, remember to add it in your
application:

```elixir
  def start(_type, _args) do
    children = [
      MyApp.Broker
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
```

## Configuring the Adapter

This library uses (elixir_nsq)[https://github.com/wistia/elixir_nsq] to
connect to the message queue. Aside from specifiying the `:adapter`,
every option in the following snippet below is passed down to `NSQ.Config`:

``` elixir
config :my_app, MyApp.Broker,
  adapter: ConduitNSQ,
  nsqds: [
    "127.0.0.1:12150",
    "127.0.0.1:13150",
    "127.0.0.1:14150"
  ],
  nsqlookupds: ["127.0.0.1:12161"],
  backoff_multiplier: 2_000
```

Checkout the (list of supported options)[https://github.com/wistia/elixir_nsq/blob/master/lib/nsq/config.ex].

For more adapter specific options:

```elixir
# Default config
config :conduit_nsq,
  publisher_workers: 3,
  processor_workers: 10,
  publish_timeout: 60_000,
  process_timeout: 60_000
```

### Options

    Aside from `:adapter`, the current options should be good defaults.

* `:adapter` - The message queue adapter to use, should be `ConduitNSQ`.
* `:publisher_workers` - The number of workers for publishing messages.
  See (Honeydew.start_workers/3)[https://hexdocs.pm/honeydew/Honeydew.html#start_workers/3]
* `:processor_workers` - The number of workers for receiving messages.
  See
  (Honeydew.start_workers/3)[https://hexdocs.pm/honeydew/Honeydew.html#start_workers/3]
* `:publish_timeout` - Timeout in publishing messages. See (Honeydew.yield/2)[https://hexdocs.pm/honeydew/Honeydew.html#yield/2]
* `:process_timeout` - Timeout in receiving messages. See (Honeydew.yield/2)[https://hexdocs.pm/honeydew/Honeydew.html#yield/2]

## Configuring Topic

Inside the `configure` block of a broker, you can define topics via
`queue` that will be created at application startup with the options you specify.

``` elixir
defmodule MyApp.Broker do
  configure do
    queue "my-topic"
    queue "other-topic"
  end
end
```

All topics that the application will publish to must be defined here
since each message is routed to the corresponding
`NSQ.Producer.Supervisor` otherwise the message might be unsent.

## Configuring a Subscriber

Inside an `incoming` block for a broker, you can define subscriptions to
topics. Conduit will route messages on those topics to your subscribers.

``` elixir
defmodule MyApp.Broker do
  incoming MyApp do
    subscribe :my_subscriber, MySubscriber,
      topic: "my-queue",
      channel: "my-channel"
    subscribe :my_other_subscriber, MyOtherSubscriber,
      topic: "my-other-queue",
      from: "my-other-channel"
  end
end
```

Make sure the `:topic`s here are found in the `configure` block to
receive the messages.

### Options

The only required options are `:topic` and `:channel` which follows
`NSQ.Consumer.Supervisor`.

## Configuring a Publisher

Inside an `outgoing` block for a broker, you can define publications to topics.

``` elixir
defmodule MyApp.Broker do
  outgoing do
    publish :something, topic: "my-topic"
    publish :something_else, topic: "my-other-topic",
  end
end
```

### Options

The only required option is `:topic` which follows
`NSQ.Producer.Supervisor`.

## Serialization

Published and received messages are sent via `NSQ.Producer.pub` as is.
If you need to make use of JSON serialization with
`ConduitNSQ.Encoding.Json` via
(Jason)[https://github.com/michalmuskala/jason], add this config:

```elixir
config :conduit, Conduit.Encoding, [
  {"json", ConduitNSQ.Encoding.Json}
]
```

You can use this via `Conduit.Plug`s like so:

```elixir
  pipeline :serialize do
    plug(Conduit.Plug.Wrap)
    plug(Conduit.Plug.Encode, content_encoding: "json")
  end

  pipeline :deserialize do
    plug(Conduit.Plug.Decode, content_encoding: "json")
    plug(Conduit.Plug.Unwrap)
  end

  incoming MyApp do
    pipe_through([:deserialize])
  end

  outgoing do
    pipe_through([:serialize])
  end
```
