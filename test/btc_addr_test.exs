defmodule BtcAddrTest do
  use ExUnit.Case
  doctest BitCoin.AddressGenerator

  # 怎么执行多次测试？
  test "generate address with p2pkh format" do
    {ok, {key_private, address}} = BitCoin.AddressGenerator.generate_address(:p2pkh)
    assert is_atom(ok)
    assert 32 = byte_size(key_private)
    assert "1" = String.first(address)
  end

  test "generate address with p2sh format" do
    {ok1, {key_private1, address1}} = BitCoin.AddressGenerator.generate_address(:p2sh)
    assert is_atom(ok1)
    assert 32 = byte_size(key_private1)
    assert "3" = String.first(address1)
  end

  test "generate address with unknow format" do
    {error, state} = BitCoin.AddressGenerator.generate_address(:hahaha)
    assert error == :error
    assert state == false
  end

  test "validate p2pkh | p2sh address" do
    assert true ==
             BitCoin.AddressGenerator.address_valid?("1DSuRixnJVD1oa1RQAsuPkcSmTSKjz7fSD", nil)

    assert true ==
             BitCoin.AddressGenerator.address_valid?("3DnH1Ffrj9HVBm4MUbQNzwJNxEqzwGrSjv", nil)

    assert false ==
             BitCoin.AddressGenerator.address_valid?("6DnH1Ffrj9HVBm4MUbQNzwJNxEqzwGrSjv", nil)

    assert false ==
             BitCoin.AddressGenerator.address_valid?("3DnH1Ffrj9HVBm4MUbQNzwJNxEqzwGrSjv1", nil)

    assert false ==
             BitCoin.AddressGenerator.address_valid?("1DnH1Ffrj9HVBm4MUbQNzwJNxEqzwGrSjv", nil)

    assert false == BitCoin.AddressGenerator.address_valid?("1DnH1Sjv", nil)
  end
end
