# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Com do

  # Com only has the number of peers in the system, but PL has the PL list.
  # Com only job is to repeatedly tell PL to send msg to other PL.
  def start(index, num_peers) do
    sent = List.duplicate(0, num_peers)
    received = List.duplicate(0, num_peers)
    # Wait for a bind message for the pl 
    receive do
      {:pl_bind, pl_pid} -> listen(pl_pid, num_peers, index, sent, received)
    end
  end

  def listen(pl_pid, num_peers, index, sent, received) do
    receive do
      { :broadcast, max_broadcasts, timeout } ->
        # create N sender to send the PL max_broadcasts send requests.
        broadcast(num_peers, max_broadcasts, pl_pid)
        # send a time out to myself
        Process.send_after(self(), {:timeout}, timeout)
        listen(pl_pid, num_peers, index, sent, received)
      { :received, sender_index } ->
        # PL passes the message to COM
        # IO.puts "Received a message from " <> "#{inspect sender_index}"
        new_received = List.update_at(received, sender_index, fn x -> x + 1 end)
        listen(pl_pid, num_peers, index, sent, new_received)
      { :sent, recipient_index } ->
        # Acknowledged a sent from PL
        new_sent = List.update_at(sent, recipient_index, fn x -> x + 1 end)
        listen(pl_pid, num_peers, index, new_sent, received)
      { :timeout } -> print_message("Peers #{index}:", sent, received, 0)
    end
  end

  defp broadcast(num_peers, max_broadcasts, pl_pid) do
    Enum.map(0..num_peers - 1, fn recipient_index -> spawn(Sender, :start, [recipient_index, max_broadcasts, pl_pid]) end)
  end

  defp print_message(string, sent, received, cnt) do
    if cnt < length(sent) do
      str = string <> "{#{inspect Enum.at(sent, cnt)}, #{inspect Enum.at(received, cnt)}},"
      print_message(str, sent, received, cnt + 1)
    else
      msg = string |> String.slice(0..-2) #removes the , at the end
      IO.puts msg
    end
  end

end
