# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Broadcast1 do

  def main do
    args = for arg <- System.argv, do: String.to_integer(arg)
    version = Enum.at(args, 0)
    num_peers = Enum.at(args, 1)

    peers = Enum.map(0..num_peers-1, fn x ->
      spawn(Peer, :start, [x])
    end)

    connect(version, peers)
  end

  def main_net do
    args = for arg <- System.argv, do: String.to_integer(arg)
    version = Enum.at(args, 0)
    num_peers = Enum.at(args, 1)

    peers = Enum.map(0.. num_peers-1, fn x ->
      Node.spawn(:'peer#{x}@peer#{x}.localdomain', Peer, :start, [x])
    end)

    connect(version, peers)
  end

  defp connect(version, peers) do
    Enum.map(peers, fn(peer) ->
      send peer, { :peers, peers }
    end)

    cond do
      version == 1 ->
        IO.puts "Broadcast1 version 1"
        Enum.map(peers, fn(peer) ->
          send peer, { :broadcast, 1000, 3000 }
        end)
      version == 2 ->
        IO.puts "Broadcast1 version 2"
        Enum.map(peers, fn(peer) ->
          send peer, { :broadcast, 10_000_000, 3000 }
        end)
      version == 3 ->
        IO.puts "Broadcast1 version 3"
        Enum.map(peers, fn(peer) ->
          send peer, { :broadcast, 1000, 0 }
        end)
    end
  end

end
