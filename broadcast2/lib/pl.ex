# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Pl do

  def start(com_pid, index) do
    # start the PL by binding the PL component to the COM it is working for.
    send com_pid, {:pl_bind, self()}
    listen_bind(index, com_pid) # listen for the bind message from Broadcast2 to bind the pl tgt
  end

  def listen_bind(index, com_pid) do
    receive do
      {:bind, pl_list} -> listen(pl_list, index, com_pid)
    end
  end

  def listen(pl_list, index, com_pid) do
    # start listening for send requests
    receive do
      {:pl_send, recipient_index} ->
        recipient = Enum.at(pl_list, recipient_index)
        # IO.puts "I am a PL, I need to send to number #{inspect recipient}"
        send recipient, {:pl_deliver, index}
        listen(pl_list, index, com_pid)

      {:pl_deliver, sender_index} ->
        # forward the message to com
        send com_pid, {:received, sender_index}
        listen(pl_list, index, com_pid)

    end
  end
  

end
