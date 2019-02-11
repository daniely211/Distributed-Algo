# Daniel Yung (lty16)  Tim Green (tpg16)

defmodule Peer do

  def start(index, num_peers, broadcast) do
    # when peer start, it will create its Com and PL component
    com_pid = spawn(Com, :start, [index, num_peers])
    pl_pid = spawn(Pl, :start, [com_pid, index])

    # send PL info to broadcast so it can inform all other PLs
    send broadcast, { :bind_bc_pl, pl_pid, index }

    # when broadcast message received, forward it to com
    receive do
      { :broadcast, msg_num, timeout } -> send com_pid, { :broadcast, msg_num, timeout }
    end
  end
end
