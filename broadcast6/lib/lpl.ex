# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Lpl do

  def start(up_stream_pid, index, reliability) do
    # start the PL by binding the PL component to the COM it is working for.
    send up_stream_pid, {:pl_bind, self()}
    # listen for the bind message from Broadcast2 to bind the pl tgt
    listen_bind(index, up_stream_pid, reliability) 
  end

  def listen_bind(index, up_stream_pid, reliability) do
    receive do
      {:bind, pl_list} -> listen(pl_list, index, up_stream_pid, reliability)
    end
  end

  def listen(lpl_list, self_index, up_stream_pid, reliability) do
    # start listening for send requests
    receive do
      #LPL uses the recipient Index to find the recipient within the LPL list
      {:pl_send, recipient_index, message} ->
        recipient = Enum.at(lpl_list, recipient_index)
        # IO.puts "I am a PL, I need to send to number #{inspect recipient}"
        rand_int = :rand.uniform(100)
        if rand_int <= reliability do
        # Here LPL changes the pl_deliver to be the self index to let the recipient know who sent it
          send recipient, {:pl_deliver, self_index, message}
        end
        listen(lpl_list, self_index, up_stream_pid, reliability)
      {:pl_deliver, sender_index, message} ->
        # forward the message to com
        # IO.puts "I GOT A MESSAGE! IN PL"
        send up_stream_pid, {:pl_deliver, sender_index, message}
        listen(lpl_list, self_index, up_stream_pid, reliability)
    end
  end

end
