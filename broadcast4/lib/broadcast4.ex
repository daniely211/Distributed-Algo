# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Broadcast4 do

  def main do
    args = for arg <- System.argv, do: String.to_integer(arg)
    version = Enum.at(args, 0)
    num_peers = Enum.at(args, 1)
    reliability = 100

    # spawn peers
    peers = Enum.map(0..num_peers - 1, fn x ->
      spawn(Peer, :start, [x, num_peers, self(), reliability])
    end)

    connect(version, peers, num_peers)
  end

  def main_net do
    args = for arg <- System.argv, do: String.to_integer(arg)
    version = Enum.at(args, 0)
    num_peers = Enum.at(args, 0)
    reliability = 100

    # spawn peers
    peers = Enum.map(0..num_peers - 1, fn x ->
      Node.spawn(:'peer#{x}@peer#{x}.localdomain', Peer, :start, [x, num_peers, self(), reliability])
    end)

    connect(version, peers, num_peers)
  end

  defp connect(version, peers, num_peers) do
    pl_list = List.duplicate(0, num_peers)
    bind_pl_together(num_peers, pl_list)

    cond do
      version == 1 ->
        IO.puts "Broadcast4 version 1"
        Enum.map(peers, fn(peer) ->
          send peer, { :broadcast, 1000, 3000}
        end)
      version == 2 ->
        IO.puts "Broadcast4 version 2"
        Enum.map(peers, fn(peer) ->
          send peer, { :broadcast, 10_000_000, 3000}
        end)
    end
  end

  defp bind_pl_together(binds_left, lpl_list) do
    if binds_left > 0 do
      receive do
        { :bind_bc_lpl, lpl_pid, index } ->
          new_lpl_list = List.update_at(lpl_list, index, fn _x -> lpl_pid end)
          bind_pl_together(binds_left - 1, new_lpl_list)
      end
    else
      # after receiving all the bind messages, it will pass the pl_list to all
      # the PLs so they know each other
      Enum.map(lpl_list, fn lpl -> send lpl, { :bind_all_lpl, lpl_list } end)
    end
  end
end
