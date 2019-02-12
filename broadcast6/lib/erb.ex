# Daniel Yung (lty16)  Tim Green (tpg16)

defmodule Erb do
  def start(up_stream_pid) do
    send up_stream_pid, { :erb_bind, self() }
    bind_Beb(up_stream_pid)
  end

  defp bind_Beb(up_stream_pid) do
    receive do
      { :beb_bind, beb_pid } -> listen(beb_pid, up_stream_pid, MapSet.new)
    end
  end

  defp listen(beb_pid, up_stream_pid, delivered) do
    # ERB will take the message number and send it down stream where it will wrap it with the peer's index in lpl
    receive do
      { :rb_broadcast, m_sender_index, seq_num } ->
        send beb_pid, { :beb_broadcast, { :rb_data, { m_sender_index, seq_num } } }
        listen(beb_pid, up_stream_pid, delivered)
      { :beb_deliver, sender_index, { :rb_data, { m_sender_index, seq_num } = message } } ->
        if (message in delivered) do
          listen(beb_pid, up_stream_pid, delivered)
        else
          send up_stream_pid, { :rb_deliver, m_sender_index }
          send beb_pid, { :beb_broadcast, message }

          # recurse and save the delivered message
          listen(beb_pid, up_stream_pid, MapSet.put(delivered, message))
        end
    end
  end

end
