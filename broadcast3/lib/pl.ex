# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Pl do

  def start(up_stream_pid, index) do
    # start the PL by binding the PL component to the COM it is working for.
    send up_stream_pid, { :bind_pl_beb, self() }

    # listen for the bind message from Broadcast3 to bind the pl tgt
    listen_bind(index, up_stream_pid)
  end

  # listen for the list of all PLs
  def listen_bind(index, up_stream_pid) do
    receive do
      { :bind_all_pl, pl_list } -> listen(pl_list, index, up_stream_pid)
    end
  end

  # start listening for send/deliver requests
  def listen(pl_list, index, up_stream_pid) do
    receive do
      { :pl_send, recipient_index } ->
        recipient = Enum.at(pl_list, recipient_index)
        send recipient, { :pl_deliver, index }
        listen(pl_list, index, up_stream_pid)

      { :pl_deliver, sender_index } ->
        # forward successful delivery message to upstream
        send up_stream_pid, { :pl_deliver, sender_index }
        listen(pl_list, index, up_stream_pid)
    end
  end
end
