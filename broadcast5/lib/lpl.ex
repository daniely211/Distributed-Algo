# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Lpl do

  def start(up_stream_pid, index, reliability) do
    # start the PL by binding the PL component to the COM it is working for.
    send up_stream_pid, { :pl_bind, self() }
    # listen for the bind message from Broadcast2 to bind the pl tgt
    listen_bind(index, up_stream_pid, reliability)
  end

  def listen_bind(index, up_stream_pid, reliability) do
    receive do
      { :bind, pl_list } -> listen(pl_list, index, up_stream_pid, reliability)
    end
  end

  def listen(lpl_list, index, up_stream_pid, reliability) do
    # start listening for send requests
    receive do
      { :pl_send, recipient_index } ->
        recipient = Enum.at(lpl_list, recipient_index)
        # IO.puts "I am a PL, I need to send to number #{inspect recipient}"
        rand_int = :rand.uniform(100)
        if rand_int <= reliability do
          send recipient, {:pl_deliver, index}
        end
        listen(lpl_list, index, up_stream_pid, reliability)
      { :pl_deliver, sender_index } ->
        # forward the message to com
        # IO.puts "I GOT A MESSAGE! IN PL"
        send up_stream_pid, {:pl_deliver, sender_index}
        listen(lpl_list, index, up_stream_pid, reliability)
    end
  end

end
