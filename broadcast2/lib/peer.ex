# Daniel Yung (lty16)  Tim Green (tpg16)

defmodule Peer do

  def start(index, num_peers, broadcast) do
    # when peer start, it will create its Com and PL component 
    com_pid = spawn(Com, :start, [index, num_peers])
    pl_pid = spawn(Pl, :start, [com_pid, index])
    # Peer must also send Broadcast the the PL pid
    send broadcast, {:bind_pl, pl_pid, index}
    receive do
      {:broadcast, msg_num, timeout} -> send com_pid, {:broadcast, msg_num, timeout}
    end
    
  end

end
