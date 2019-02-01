# Daniel Yung (lty16)  Tim Green (tpg16)

defmodule Sender do

  def start(sender_pid, recipient_pid, sender_index, recipient_index, send_total) do
    if send_total > 0 do
      send recipient_pid, { :received, sender_index } # send the message to the recipient
      send sender_pid, { :sent, recipient_index } # tell the parent the message has been sent
      start(sender_pid, recipient_pid, sender_index, recipient_index, send_total - 1)
    end
  end
end
