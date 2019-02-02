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
        broadcast(beb_pid, max_broadcasts, 1, self_index, timeout, sent, received)
    end
  end


defp broadcast(beb_pid, max_broadcasts, num_broadcasts, self_index, timeout, sent, received) do
    # broadcast needs to be in a send and receive loop
    if num_broadcasts > max_broadcasts do
      # this case we will keep listening after we are done broadcasting... because we will send more than we listen
      listen(beb_pid, max_broadcasts, num_broadcasts, self_index, timeout, sent, received)
    else
      # Tell Beb to broadcast!
      send beb_pid, {:beb_broadcast} 
      # Update the sent list since we send a beb broadcast, we increase sent for all the peers
      new_sent = Enum.map(sent, fn x -> x + 1 end)
      listen(beb_pid, max_broadcasts, num_broadcasts + 1, self_index, timeout, new_sent, received)
    end
  end


  defp listen(beb_pid, max_broadcasts, num_broadcasts, self_index, timeout, sent, received) do
    # pid = self()
    # listen once, then send another broadcast.
    receive do
    { :beb_deliver, sender_index} ->
      # IO.puts "received a message from a peer! #{inspect pid}"
      # Received a message from downstream
      new_received = List.update_at(received, sender_index, fn x -> x + 1 end)
      # broadcast again
      broadcast(beb_pid, max_broadcasts, num_broadcasts, self_index, timeout, sent, new_received)
    after 
      timeout ->
      print_message("Peer #{self_index}:", sent, received, 0)
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
