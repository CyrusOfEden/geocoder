defmodule Geocoder.StoreTest do
  use ExUnit.Case, async: false

  alias Geocoder.Store

  import Geocoder.Support.Helpers

  setup do
    {:ok, pid} = start_supervised({Store, [precision: 6]})

    {:ok, pid: pid}
  end

  describe "init/1" do
    test "Store use default configuration", %{pid: pid} do
      assert {%{}, %{}, [precision: 6]} = Store.state(pid)
    end

    test "Store accepts configuration" do
      # need to specify the id here when using the supervised
      {:ok, pid} = start_supervised({Store, [precision: 3, name: :toto]}, id: :toto)

      assert {_links, _store, [precision: 3]} = Store.state(pid)
    end
  end

  describe "update/1" do
    test "Store the location in state", %{pid: pid} do
      coord = belgium_coords()

      erlang_version = :erlang.system_info(:otp_release) |> List.to_string()

      # the key is different depending on the elixir version
      key =
        if Version.compare(erlang_version, "26.0") in [:eq, :gt],
          do: "ZmxhbmRlcnNnaGVudGJlbGdpdW0=",
          else: "Z2hlbnRiZWxnaXVtZmxhbmRlcnM="

      assert ^coord = Store.update(pid, coord)

      assert {%{^key => "u14ds6"}, %{"u14ds6" => ^coord}, [precision: 6]} = Store.state(pid)
    end
  end

  describe "geocode/1" do
    test "Find location in Store", %{pid: pid} do
      coord = belgium_coords()

      Store.update(pid, coord)

      assert :nothing =
               Store.geocode(pid,
                 address:
                   "Dikkelindestraat, Wondelgem, Ghent, Gent, East Flanders, Flanders, 9032, Belgium"
               )
    end

    test "Does not find location in Store", %{pid: pid} do
      assert :nothing =
               Store.geocode(pid,
                 address:
                   "Dikkelindestraat, Wondelgem, Ghent, Gent, East Flanders, Flanders, 9032, Belgium"
               )
    end
  end

  describe "reverse_geocode/1" do
    test "Find location in Store", %{pid: pid} do
      coord = belgium_coords()

      Store.update(pid, coord)

      assert {:just, ^coord} = Store.reverse_geocode(pid, latlng: {51.0772661, 3.7074267})
    end

    test "Does not find location in Store", %{pid: pid} do
      assert :nothing = Store.reverse_geocode(pid, latlng: {51.0772661, 3.7074267})
    end
  end
end
