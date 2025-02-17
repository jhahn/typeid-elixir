defmodule TypeIDTest do
  use ExUnit.Case, async: true
  doctest TypeID, except: [new: 2]

  describe "new/1" do
    test "returns a new TypeID struct" do
      tid = TypeID.new("test")
      assert is_struct(tid, TypeID)
      assert "test" == TypeID.prefix(tid)
    end
  end

  describe "new/2" do
    test "allows setting the time" do
      time = ~U[1950-12-17 00:00:00Z] |> DateTime.to_unix(:millisecond)
      tid = TypeID.new("test", time: time)
      assert "test" == TypeID.prefix(tid)
      assert "7zegbdn300" <> _ = TypeID.suffix(tid)
    end

    test "allows setting the UUID version to 4" do
      tid = TypeID.new("test", v: 4)
      assert "test" == TypeID.prefix(tid)
      assert <<_u0::48, 4::4, _u1::12, 2::2, _u2::62>> = TypeID.uuid_bytes(tid)
    end

    test "allows setting the UUID version to 7" do
      tid = TypeID.new("test", v: 7)
      assert "test" == TypeID.prefix(tid)

      assert <<_time::big-unsigned-integer-size(48), 7::4, _rand_a::12, 2::2, _rand_b::62>> =
               TypeID.uuid_bytes(tid)
    end
  end

  describe "prefix/1" do
    test "returns the prefix of the given TypeID" do
      tid = TypeID.from_string!("test_01h44had5rfswbvpc383ktj0aa")
      assert "test" == TypeID.prefix(tid)
    end
  end

  describe "suffix/1" do
    test "returns the base 32 suffix of the given TypeID" do
      tid = TypeID.from_string!("test_01h44had5rfswbvpc383ktj0aa")
      assert "01h44had5rfswbvpc383ktj0aa" == TypeID.suffix(tid)
    end
  end

  describe "serialization" do
    test "to_string/1 and from_string!/1 are idempotent" do
      tid1 = TypeID.from_string!("test_01h44had5rfswbvpc383ktj0aa")

      tid2 =
        tid1
        |> TypeID.to_string()
        |> TypeID.from_string!()

      assert tid1 == tid2
    end

    test "from_string/1" do
      assert {:ok, _} = TypeID.from_string("test_01h44xf16gf47v3s4khvc3c5ga")
      assert :error == TypeID.from_string("-invalid_01h44xf16gf47v3s4khvc3c5ga")
    end

    test "from!/2 and from/2 validates the prefix" do
      assert_raise ArgumentError, fn ->
        TypeID.from!("-invalid-prefix-", "01h44had5rfswbvpc383ktj0aa")
      end

      assert :error == TypeID.from("-invalid-prefix-", "01h44had5rfswbvpc383ktj0aa")
    end

    test "from!/2 and from/2 validate the suffix" do
      assert_raise ArgumentError, fn ->
        TypeID.from!("test", "0ih44had5rfswbvpc383ktj0aa")
      end

      assert :error == TypeID.from("test", "0ih44had5rfswbvpc383ktj0aa")
    end
  end

  test "verification" do
    tid = TypeID.from_string!("test_01h44yssjcf5daefvfr0yb70s8")
    assert "test" == TypeID.prefix(tid)
    assert "018909ec-e64c-795a-a73f-6fc03cb38328" == TypeID.uuid(tid)
  end
end
