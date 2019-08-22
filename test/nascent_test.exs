defmodule NascentTest do
  use ExUnit.Case

  alias NSQ.Producer

  test "sandbox" do
    {:ok, p1} =
      NSQ.Producer.Supervisor.start_link(
        "my-topic-C",
        %NSQ.Config{
          # nsqds: ["127.0.0.1:12150", "127.0.0.1:13150", "127.0.0.1:14150" ],
          nsqlookupds: ["127.0.0.1:12161"]
        }
      )

    {:ok, "OK"} = Producer.pub(p1, "cat")
    {:ok, "OK"} = Producer.pub(p1, "dog")
  end
end
