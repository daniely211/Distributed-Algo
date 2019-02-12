# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Broadcast6 do

  def main do
    args = for arg <- System.argv, do: String.to_integer(arg)
    reliability = Enum.at(args, 0)
    num_peers = Enum.at(args, 1)

    peers = Enum.map(0..num_peers - 1, fn x -> spawn(Peer, :start, [x, num_peers, self(), reliability]) end)

    pl_list = List.duplicate(0, num_peers)
    bind_all_pl(num_peers, pl_list)

    IO.puts "Broadcast6 reliability: #{reliability}"
    Enum.map(peers, fn(peer) ->
      send peer, { :broadcast, 5000, 3000 }
    end)
  end

  def main_net do
    args = for arg <- System.argv, do: String.to_integer(arg)
    reliability = Enum.at(args, 0)
    num_peers = Enum.at(args, 1)

    # spawn peers
    peers = Enum.map(0..num_peers - 1, fn x ->
      Node.spawn(:'peer#{x}@peer#{x}.localdomain', Peer, :start, [x, num_peers, self(), reliability])
    end)

    # Perfect link
    pl_list = List.duplicate(0, num_peers)
    bind_all_pl(num_peers, pl_list)

    IO.puts "Broadcast6 reliability: #{reliability}"
    Enum.map(peers, fn(peer) ->
      send peer, { :broadcast, 1000, 3000 }
    end)
  end

  defp bind_all_pl(binds_left, lpl_list) do
    if binds_left > 0 do
      receive do
        { :bind_lpl, lpl_pid, index } ->
        new_lpl_list = List.update_at(lpl_list, index, fn _x -> lpl_pid end)
        bind_all_pl(binds_left - 1, new_lpl_list)
      end
    else
      # after receiving all the bind messages, it will pass the pl_list to all the PL so they know each other.
      Enum.map(lpl_list, fn lpl -> send lpl, { :bind, lpl_list } end)
    end
  end
end
