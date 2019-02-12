# Daniel Yung (lty16)  Tim Green (tpg16)

defmodule Beb do
  def start(up_stream_pid, num_peers) do
    send up_stream_pid, { :beb_bind, self() }
    bind_PL(up_stream_pid, num_peers)
  end

  defp bind_PL(up_stream_pid, num_peers) do
    receive do
      { :pl_bind, pl_pid } -> listen(up_stream_pid, num_peers, pl_pid)
    end
  end

  def listen(up_stream_pid, num_peers, pl_pid) do
    receive do
      { :beb_broadcast, message } ->
        # send PL a broadcast request (aka send a message to all the peers)
        Enum.map(0..num_peers - 1 , fn i -> send pl_pid, { :pl_send, i, message } end)
        listen(up_stream_pid, num_peers, pl_pid)

      { :pl_deliver, sender_index, message } ->
        send up_stream_pid, { :beb_deliver, sender_index, message }
        listen(up_stream_pid, num_peers, pl_pid)
    end
  end
end
