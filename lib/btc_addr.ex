defmodule BitCoin.AddressGenerator do
  @moduledoc """
  Documentation for `BitCoin.AddressGenerator`.
  reference:
  - http://gobittest.appspot.com/Address
  - https://github.com/KamilLelonek/ex_wallet
  """

  alias BitCoin.{Crypto, KeyPair}
  alias Base58Check

  @doc """
  Generate P2PKH and P2SH address
  """
  def generate_address(type) do
    {_key_public, key_private} = KeyPair.generate()
    address_type = if type == nil, do: :p2pkh, else: type

    case address_type do
      :p2pkh -> {:ok, {key_private, calculate(key_private, type)}}
      :p2sh -> {:ok, {key_private, calculate(key_private, type)}}
      _ -> {:error, false}
    end
  end

  @doc """
  https://github.com/btcsuite/btcutil/blob/24e673ae72b5b4fad36808ae685489b2c26468e2/address.go#L136
  P2PKH and P2SH address format validation
  1: 验证地址原始数据长度
  2: 判断网络id
  3: 验证 checksum
  """
  def address_valid?(address, _type) do
    with true <- address_length_valid?(address),
         true <- address_network_valid?(address),
         true <- address_checksum_valid?(address),
         do: true
  end

  defp address_length_valid?(address) do
    case address |> Base58Check.decode58zero!() |> byte_size() do
      25 -> true
      _ -> false
    end
  end

  defp address_network_valid?(address) do
    case address |> Base58Check.decode58zero!() |> binary_part(0, 1) do
      <<0>> -> true
      <<5>> -> true
      _ -> false
    end
  end

  defp address_checksum_valid?(address) do
    bin = address |> Base58Check.decode58zero!()
    payload = binary_part(bin, 0, 21)
    checksum = binary_part(bin, 25, -4)
    checksum(payload) == checksum
  end

  defp checksum(payload) do
    payload |> binary_part(0, 21) |> Crypto.sha256() |> Crypto.sha256() |> binary_part(0, 4)
  end

  defp calculate(private_key, address_type, network \\ :main) do
    private_key
    |> KeyPair.to_public_key()
    |> Crypto.hash_160()
    |> Base58Check.encode58check(address_type, network)
  end
end
