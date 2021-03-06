# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Peer do

  def start(self_index, num_peers, network, reliability) do
    # when peer start, it will create its Com and PL component
    com_pid = spawn(Com, :start, [self_index, num_peers])

    if self_index == 3 do
      Process.send_after(com_pid, { :kill }, 5)
    end

    beb_pid = spawn(Beb, :start, [com_pid, num_peers])
    lpl_pid = spawn(Lpl, :start, [beb_pid, self_index, reliability])

    # Peer must also send Broadcast the the PL pid
    send network, { :bind_lpl, lpl_pid, self_index }
    listen(com_pid)
  end

  defp listen(com_pid) do
    receive do
      { :broadcast, msg_num, timeout} -> send com_pid, { :broadcast, msg_num, timeout }
    end
  end
end
