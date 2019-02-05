# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Broadcast3 do

  def main do
    args = for arg <- System.argv, do: String.to_integer(arg)
    version = Enum.at(args, 0)
    num_peers = Enum.at(args, 1)
    # Perfect link
    # Broad cast spawns all the peers
    peers = Enum.map(0..num_peers-1, fn x -> spawn(Peer, :start, [x, num_peers, self()]) end)
    pl_list = List.duplicate(0, num_peers)
    bind_all_pl(num_peers, pl_list)
  
    # This is PL connection
    if version == 1 do
      IO.puts "Broadcast3 version 1"
      Enum.map(peers, fn(peer) ->
        send peer, { :broadcast, 1000, 3000}
      end) 
    end
    if version == 2 do
      IO.puts "Broadcast3 version 2"
      Enum.map(peers, fn(peer) ->
        send peer, { :broadcast, 10_000_000, 3000}
      end) 
    end
    
  end

  defp bind_all_pl(binds_left, pl_list) do
    if binds_left > 0 do
      receive do
        {:bind_pl, pl_pid, index} ->
        new_pl_list = List.update_at(pl_list, index, fn _x -> pl_pid end)
        bind_all_pl(binds_left - 1, new_pl_list)
      end
    else
      # after receiving all the bind messages, it will pass the pl_list to all the PL so they know each other.
      Enum.map(pl_list, fn pl -> send pl, {:bind, pl_list} end)
    end
  end


  def main_net do
    # p0 = Node.spawn(:'peer0@peer0.localdomain', Peer, :start, [0])
    # p1 = Node.spawn(:'peer1@peer1.localdomain', Peer, :start, [1])
    # p2 = Node.spawn(:'peer2@peer2.localdomain', Peer, :start, [2])
    # p3 = Node.spawn(:'peer3@peer3.localdomain', Peer, :start, [3])
    # p4 = Node.spawn(:'peer4@peer4.localdomain', Peer, :start, [4])
    # peers = [p0, p1, p2, p3, p4]

    # Enum.map(peers, fn(peer) ->
    #   send peer, { :peers, peers }
    # end)

    # Enum.map(peers, fn(peer) ->
    #   send peer, { :broadcast, 1000 }
    #   # This still doesnt work on docker?!
    #   Process.send_after(peer, {:timeout}, 3000)
    # end)
  end

end
