# Daniel Yung (lty16)  Tim Green (tpg16)

defmodule Erb do
  def start(up_stream_pid) do
    send up_stream_pid, {:erb_bind, self()}
    bind_Beb(up_stream_pid)
  end

  defp bind_Beb(up_stream_pid) do
    receive do
      {:beb_bind, beb_pid} -> listen(beb_pid, up_stream_pid, MapSet.new)
    end
  end

  defp listen(beb_pid, up_stream_pid, delivered) do
    pid = self()
    # ERB will take the message number and send it down stream where it will wrap it with the peer's index in lpl
    receive do
      {:rb_broadcast, message_pid, seq_num} ->
        # IO.puts "SENDING A MESSAGE! IN ERB"
        send beb_pid, {:beb_broadcast, {:rb_data, {message_pid, seq_num}} }
        listen(beb_pid, up_stream_pid, delivered)
      {:beb_deliver, sender_index, {:rb_data, {message_pid, seq_num} = message} } ->
        # IO.puts "I GOT A MESSAGE! IN ERB"
        if ({message_pid, seq_num} in delivered) do
          listen(beb_pid, up_stream_pid, delivered)
        else
          send up_stream_pid, {:rb_deliver, sender_index}
          send beb_pid, {:beb_broadcast, message}
          listen(beb_pid, up_stream_pid, MapSet.put(delivered, {message_pid, seq_num}))
        end
    end
  end

end
