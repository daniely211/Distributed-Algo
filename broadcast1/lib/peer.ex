# Daniel Yung (lty16)  Tim Green (tpg16)

defmodule Peer do

  def start(index, num_peers) do
    sent = List.duplicate(0, num_peers)
    received = List.duplicate(0, num_peers)
    # pid = self()
    receive do
      { :peers, peers } -> listen_broadcast(peers, index, sent, received)
    end
  end

  defp print_message(string, sent, received, cnt) do
    if cnt < length(sent) do
      str = string <> "{#{inspect Enum.at(sent, cnt)}, #{inspect Enum.at(received, cnt)}},"
      print_message(str, sent, received, cnt + 1)
    else
      msg = string |> String.slice(0..-2)
      IO.puts msg
    end
  end

  defp listen_broadcast(peers, index, sent, received) do
    receive do
      { :broadcast, max_broadcasts, timeout} ->
        Process.send_after(self(), {:timeout}, timeout)
        broadcast(peers, max_broadcasts, 1, index, 0, timeout, sent, received)
    end
  end

  defp broadcast(peers, max_broadcast, num_broadcast, self_index, recipient_index, timeout, sent, received) do
    receive do
      {:timeout} -> print_message("Peer #{self_index}:", sent, received, 0)
    after 0 ->
      # pid = self()
      # IO.puts "Sending a message from a peer! #{inspect pid}"
      if recipient_index > length(peers) - 1 do
        # you have sent to all your peers increment the boradcast by 1
        if num_broadcast + 1 > max_broadcast do
          # sent enough broadcast to everyone! TIME TO STOP
          print_message("Peer #{self_index}:", sent, received, 0)
        else
          broadcast(peers, max_broadcast, num_broadcast + 1, self_index, 0, timeout, sent, received)
        end
      else
        send Enum.at(peers, recipient_index), {:received, self_index} # send the message to the recipient
        new_sent = List.update_at(sent, recipient_index, fn x -> x + 1 end)
        listen(peers, max_broadcast, num_broadcast, self_index, recipient_index + 1, timeout, new_sent, received)
      end
    end
  end

  defp listen(peers, max_broadcast, num_broadcast, self_index, recipient_index, timeout, sent, received) do
    # pid = self()
    receive do
    { :received, sender_index } ->
      # IO.puts "received a message from a peer! #{inspect pid}"
      # Received a message from sender
      new_received = List.update_at(received, sender_index, fn x -> x + 1 end)
      broadcast(peers, max_broadcast, num_broadcast, self_index, recipient_index, timeout, sent, new_received)
    {:timeout} -> print_message("Peer #{self_index}:", sent, received, 0)
    after 
      timeout ->
      print_message("Peer #{self_index}:", sent, received, 0)
    end
  
  end

end
