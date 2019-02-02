# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Broadcast5 do

  def main do
    args = for arg <- System.argv, do: String.to_integer(arg)
    version = Enum.at(args, 0)
    num_peers = Enum.at(args, 1)

  
    # This is PL connection
    if version == 1 do
      IO.puts "Broadcast5 version 1"
      # Perfect link
      # Broad cast spawns all the peers
      peers = Enum.map(0..num_peers-1, fn x -> spawn(Peer, :start, [x, num_peers, self()]) end)
      pl_list = List.duplicate(0, num_peers)
      bind_all_pl(num_peers, pl_list)
      Enum.map(peers, fn(peer) ->
        send peer, { :broadcast, 1000, 3000}
      end) 
    end
    
  end

  defp bind_all_pl(binds_left, lpl_list) do
    if binds_left > 0 do
      receive do
        {:bind_lpl, lpl_pid, index} ->
        new_lpl_list = List.update_at(lpl_list, index, fn x -> lpl_pid end)
        bind_all_pl(binds_left - 1, new_lpl_list)
      end
    else
      # after receiving all the bind messages, it will pass the pl_list to all the PL so they know each other.
      Enum.map(lpl_list, fn lpl -> send lpl, {:bind, lpl_list} end)
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
