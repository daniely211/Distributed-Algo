# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Broadcast1 do

  def main do
    args = for arg <- System.argv, do: String.to_integer(arg)
    version = Enum.at(args, 0)
    num_peers = Enum.at(args, 1)
    peers = Enum.map(0..num_peers-1, fn x -> spawn(Peer, :start, [x, num_peers]) end)
    Enum.map(peers, fn(peer) ->
      send peer, { :peers, peers }
    end)

    if version == 1 do
      IO.puts "Broadcast1 version 1"
      Enum.map(peers, fn(peer) ->
        send peer, { :broadcast, 1000, 3000}
      end)
    end

    if version == 2 do
      IO.puts "Broadcast1 version 2"
      Enum.map(peers, fn(peer) ->
        send peer, { :broadcast, 10_000_000, 3000}
      end)
    end
    
  end

  def main_net do
    args = for arg <- System.argv, do: String.to_integer(arg)
    version = Enum.at(args, 0)
    num_peers = 5

    p0 = Node.spawn(:'peer0@peer0.localdomain', Peer, :start, [0, num_peers])
    p1 = Node.spawn(:'peer1@peer1.localdomain', Peer, :start, [1, num_peers])
    p2 = Node.spawn(:'peer2@peer2.localdomain', Peer, :start, [2, num_peers])
    p3 = Node.spawn(:'peer3@peer3.localdomain', Peer, :start, [3, num_peers])
    p4 = Node.spawn(:'peer4@peer4.localdomain', Peer, :start, [4, num_peers])

    # peers = Enum.map(0.. num_peers-1, fn x -> Node.spawn(:'peer' <> x <> '@peer'<> x <> '.localdomain', Peer, :start, [x, num_peers]) end)


    peers = [p0, p1, p2, p3, p4]

    Enum.map(peers, fn(peer) ->
      send peer, { :peers, peers }
    end)

    if version == 1 do
      IO.puts "Broadcast1 version 1"
      Enum.map(peers, fn(peer) ->
        send peer, { :broadcast, 1000, 3000}
      end)
    end

    if version == 2 do
      IO.puts "Broadcast1 version 2"
      Enum.map(peers, fn(peer) ->
        send peer, { :broadcast, 10_000_000, 3000}
      end)
    end

  end


end
