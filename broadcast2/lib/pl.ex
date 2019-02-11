# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Pl do

  def start(com_pid, index) do
    # start the PL by binding the PL component to the COM it is working for.
    send com_pid, { :pl_com_bind, self() }

    # listen for the bind message from Broadcast2 to bind the pl tgt
    listen_bind(index, com_pid)
  end

  # listen for the list of all PLs
  def listen_bind(index, com_pid) do
    receive do
      { :bind_all_pl, pl_list } -> listen(pl_list, index, com_pid)
    end
  end

  # start listening for send/deliver requests
  def listen(pl_list, index, com_pid) do
    # start listening for send requests
    receive do
      { :pl_send, recipient_index } ->
        recipient = Enum.at(pl_list, recipient_index)
        send recipient, { :pl_deliver, index }
        listen(pl_list, index, com_pid)

      { :pl_deliver, sender_index } ->
        # forward successful delivery message to com
        send com_pid, { :received, sender_index }
        listen(pl_list, index, com_pid)
    end
  end
end
