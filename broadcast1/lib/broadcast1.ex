# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Broadcast1 do

  def main do
    peers = Enum.map(1..5, fn _x -> spawn(Peer, :start, []) end)

    Enum.map(peers, fn(peer) -> 
      send peer, { :peers, peerList }
    end)

    Enum.map(peers, fn(peer) -> 
      send peer, {:broadcast, 1000, 3000}
    end)

  end
end
