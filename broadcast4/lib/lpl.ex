# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Lpl do

  def start(up_stream_pid, index, reliability) do
    # start the PL by binding the PL component to the COM it is working for.
    send up_stream_pid, { :bind_lpl_beb, self() }
    # listen for the bind message from Broadcast4 to bind the pl tgt
    listen_bind(index, up_stream_pid, reliability)
  end

  def listen_bind(index, up_stream_pid, reliability) do
    receive do
      { :bind_all_lpl, pl_list } -> listen(pl_list, index, up_stream_pid, reliability)
    end
  end

  def listen(lpl_list, index, up_stream_pid, reliability) do
    # start listening for send requests
    receive do
      { :pl_send, recipient_index } ->
        recipient = Enum.at(lpl_list, recipient_index)
        rand_int = :rand.uniform(100)
        if rand_int <= reliability do
          send recipient, { :pl_deliver, index }
        end
        listen(lpl_list, index, up_stream_pid, reliability)

      { :pl_deliver, sender_index } ->
        # forward the message to com
        send up_stream_pid, { :pl_deliver, sender_index }
        listen(lpl_list, index, up_stream_pid, reliability)
    end
  end
end
