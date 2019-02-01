# Daniel Yung (lty16)  Tim Green (tpg16)

defmodule Sender do

  def start(recipient_index, send_total, pl_pid) do
    if send_total > 0 do
      send pl_pid, {:pl_send, recipient_index } # Tell PL to send a message to recipient_index
      start(recipient_index, send_total - 1, pl_pid)
    end
  end
end
