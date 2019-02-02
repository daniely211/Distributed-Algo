# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Pl do

  def start(up_stream_pid, index) do
    # start the PL by binding the PL component to the COM it is working for.
    send up_stream_pid, {:pl_bind, self()}
    # listen for the bind message from Broadcast2 to bind the pl tgt
    listen_bind(index, up_stream_pid) 
  end

  def listen_bind(index, up_stream_pid) do
    receive do
      {:bind, pl_list} -> listen(pl_list, index, up_stream_pid)
    end
  end

  def listen(pl_list, index, up_stream_pid) do
    # start listening for send requests
    receive do
      {:pl_send, recipient_index} ->
        recipient = Enum.at(pl_list, recipient_index)
        # IO.puts "I am a PL, I need to send to number #{inspect recipient}"
        send recipient, {:pl_deliver, index}
        # IO.puts "Now i inform my COM #{inspect up_stream_pid}"
        send up_stream_pid, {:sent, recipient_index}
        listen(pl_list, index, up_stream_pid)
      {:pl_deliver, sender_index} ->
        # forward the message to com
        # IO.puts "I GOT A MESSAGE! IN PL"
        send up_stream_pid, {:pl_deliver, sender_index}
        listen(pl_list, index, up_stream_pid)
    end
  end

end
