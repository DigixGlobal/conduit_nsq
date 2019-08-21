defmodule NascentTest do
  use ExUnit.Case
  doctest Nascent

  test "greets the world" do
    assert Nascent.hello() == :world
  end
end
