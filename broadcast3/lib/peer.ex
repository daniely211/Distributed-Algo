# Daniel Yung (lty16)  Tim Green (tpg16)

defmodule Peer do

  def start(self_index, num_peers, network) do
    # when peer start, it will create its Com and PL component 
    com_pid = spawn(Com, :start, [self_index, num_peers])
    beb_pid = spawn(Beb, :start, [com_pid, num_peers])
    pl_pid = spawn(Pl, :start, [beb_pid, self_index])

    # Peer must also send Broadcast the the PL pid
    send network, {:bind_pl, pl_pid, self_index}
    listen(com_pid)
  end

  defp listen(com_pid) do
    receive do
        {:broadcast, msg_num, timeout} -> send com_pid, {:broadcast, msg_num, timeout}
    end
  end

end
