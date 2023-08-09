defmodule Geocoder.JSONCodec.JSXTest do
  use ExUnit.Case
  alias Geocoder.JSONCodec.JSX

  describe "decode/1" do
    test "decodes correctly the payload" do
      encoded = Jason.encode!(%{hello: "world"})
      assert %{"hello" => "world"} == JSX.decode!(encoded)
    end
  end

  describe "encode/1" do
    test "encodes correctly the payload" do
      encoded = JSX.encode!(%{hello: "world"})
      assert %{"hello" => "world"} == JSX.decode!(encoded)
    end
  end
end
