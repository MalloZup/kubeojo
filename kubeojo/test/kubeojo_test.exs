defmodule KubeojoTest do
  use ExUnit.Case
  doctest Kubeojo

  test "greets the world" do
    assert Kubeojo.hello() == :world
  end
end
