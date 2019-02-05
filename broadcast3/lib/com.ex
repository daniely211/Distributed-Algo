# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Com do

  # Com only has the number of peers in the system, but PL has the PL list.
  # Com only job is to repeatedly tell PL to send msg to other PL.
  def start(self_index, num_peers) do
    sent = List.duplicate(0, num_peers)
    received = List.duplicate(0, num_peers)
    # Wait for a bind message from beb
    receive do
      {:beb_bind, beb_pid} -> listen_instruction(beb_pid, self_index, sent, received)
    end
  end

  def listen_instruction(beb_pid, self_index, sent, received) do
    receive do
      { :broadcast, max_broadcasts, timeout } ->
        Process.send_after(self(), {:timeout}, timeout)
        broadcast(beb_pid, max_broadcasts, 1, self_index, timeout, sent, received)
    end
  end


  defp broadcast(beb_pid, max_broadcasts, num_broadcasts, self_index, timeout, sent, received) do
    # broadcast needs to be in a send and receive loop
    # pid = self()
    receive do
      {:timeout} -> print_message("Peer #{self_index}:", sent, received, 0)
    after 
      0 ->
      if num_broadcasts > max_broadcasts do
        print_message("Peer #{self_index}:", sent, received, 0)
      else
        # Tell Beb to broadcast!
        # IO.puts "Sending a message to PL! #{inspect pid}, #{inspect beb_pid}" 
        send beb_pid, {:beb_broadcast} 
        # Update the sent list since we send a beb broadcast, we increase sent for all the peers
        new_sent = Enum.map(sent, fn x -> x + 1 end)
        listen(beb_pid, max_broadcasts, num_broadcasts + 1, self_index, timeout, new_sent, received, 1)
      end
    end
  end

  defp listen(beb_pid, max_broadcasts, num_broadcasts, self_index, timeout, sent, received, cnt) do
    # pid = self()
    # becasue broadcast sends N messages at the same time, we will listen to N messages and then send another N
    if cnt > length(sent)  do
      broadcast(beb_pid, max_broadcasts, num_broadcasts, self_index, timeout, sent, received)
    else
      # havent heard N messages yet!
      receive do
      { :beb_deliver, sender_index} ->
        # IO.puts "received a message from a peer! #{inspect pid}"
        # Received a message from downstream
        new_received = List.update_at(received, sender_index, fn x -> x + 1 end)
        # listen again
        listen(beb_pid, max_broadcasts, num_broadcasts, self_index, timeout, sent, new_received, cnt + 1)
      after 
        timeout ->
        print_message("Peer #{self_index}:", sent, received, 0)
      end
    end
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
