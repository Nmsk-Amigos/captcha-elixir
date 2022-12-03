defmodule AgogoTest do
  use ExUnit.Case
  doctest Agogo

  test "greets the world" do
    assert Agogo.hello() == :world
  end
end
