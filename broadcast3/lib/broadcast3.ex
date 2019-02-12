# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Broadcast3 do

  def main do
    args = for arg <- System.argv, do: String.to_integer(arg)
    version = Enum.at(args, 0)
    num_peers = Enum.at(args, 1)

    peers = Enum.map(0..num_peers - 1, fn x -> spawn(Peer, :start, [x, num_peers, self()]) end)

    connect(version, peers, num_peers)
  end

  def main_net do
    args = for arg <- System.argv, do: String.to_integer(arg)
    version = Enum.at(args, 0)
    num_peers = Enum.at(args, 1)

    # spawn peers
    peers = Enum.map(0.. num_peers - 1, fn x ->
      Node.spawn(:'peer#{x}@peer#{x}.localdomain', Peer, :start, [x, num_peers, self()])
    end)

    connect(version, peers, num_peers)
  end

  defp connect(version, peers, num_peers) do
    pl_list = List.duplicate(0, num_peers)
    bind_pl_together(num_peers, pl_list)

    cond do
      version == 1 ->
        IO.puts "Broadcast3 version 1"
        Enum.map(peers, fn(peer) ->
          send peer, { :broadcast, 1000, 3000 }
        end)
      version == 2 ->
        IO.puts "Broadcast3 version 2"
        Enum.map(peers, fn(peer) ->
          send peer, { :broadcast, 10_000_000, 3000 }
        end)
        #2,505,400
      version == 3 ->
      IO.puts "Broadcast3 version 3"
      Enum.map(peers, fn(peer) ->
        send peer, { :broadcast, 10_000_000, 6000 }
      end)
      # 3,674,296
    end
  end

  defp bind_pl_together(binds_left, pl_list) do
    if binds_left > 0 do
      receive do
        { :bind_bc_pl, pl_pid, index } ->
          new_pl_list = List.update_at(pl_list, index, fn _x -> pl_pid end)
          bind_pl_together(binds_left - 1, new_pl_list)
      end
    else
      # after receiving all the bind messages, it will pass the pl_list to all
      # the PLs so they know each other
      Enum.map(pl_list, fn pl -> send pl, { :bind_all_pl, pl_list } end)
    end
  end
end
