defmodule ConduitNSQ.Encoding.JsonSpec do
  use ESpec
  use Quixir

  alias Conduit.Message
  alias Jason

  describe "JSON Encoding" do
    it "encode/2 should work" do
      ptest(original: choose(from: [list(of: string()), string()])) do
          message = %Message{}
          |> Message.put_body(original)
          |> described_module().encode([])

          message
          |> expect()
          |> to(be_struct())

          message
          |> Map.get(:body)
          |> Jason.decode()
          |> expect()
          |> to(match_pattern {:ok, ^original})
        end
    end

    it "decode/2 should work" do
      ptest(original: choose(from: [list(of: string()), string()])) do
        encoded = Jason.encode!(original)

          message = %Message{}
          |> Message.put_body(encoded)
          |> described_module().decode([])

          message
          |> expect()
          |> to(be_struct())

          message
          |> Map.get(:body)
          |> Jason.encode()
          |> expect()
          |> to(match_pattern {:ok, ^encoded})
        end
    end

    it "decode and encode are inverse operations" do
      ptest(original: choose(from: [list(of: string()), string()])) do
          message = %Message{}
          |> Message.put_body(original)
          |> described_module().encode([])
          |> described_module().decode([])

          message
          |> expect()
          |> to(be_struct())

          message
          |> Map.get(:body)
          |> expect()
          |> to(eq(original))
        end
    end
  end
end
