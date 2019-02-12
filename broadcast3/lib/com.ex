# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Com do
  # Coms only job is to repeatedly tell PL to send messages to other PLs

  # wait for a bind message for the beb
  def start(self_index, num_peers) do
    receive do
      { :bind_beb_com, beb_pid } -> listen_instruction(beb_pid, self_index, num_peers)
    end
  end

  # wait for a broadcast message
  def listen_instruction(beb_pid, self_index, num_peers) do
    sent = List.duplicate(0, num_peers)
    received = List.duplicate(0, num_peers)

    receive do
      { :broadcast, max_broadcasts, timeout } ->
        Process.send_after(self(), { :timeout }, timeout)
        broadcast(beb_pid, max_broadcasts, self_index, sent, received)
    end
  end

  # print the current status
  defp print_message(string, sent, received, cnt) do
    if cnt < length(sent) do
      str = string <> "{#{inspect Enum.at(sent, cnt)}, #{inspect Enum.at(received, cnt)}},"
      print_message(str, sent, received, cnt + 1)
    else
      msg = string |> String.slice(0..-2) #removes the , at the end
      IO.puts msg
    end
  end

  # send broadcast messages to BEB
  defp broadcast(beb_pid, max_broadcasts, self_index, sent, received) do
    receive do
      { :timeout } -> print_message("Peer #{self_index}:", sent, received, 0)
    after
      0 ->
        if max_broadcasts <= 0 do
          # if broadcasting finished, just listen for new messages
          listen(beb_pid, max_broadcasts, self_index, sent, received)
        else
          # tell Beb to broadcast
          send beb_pid, { :beb_broadcast }
          # update the sent list since we send a beb broadcast, we increase sent for all the peers
          new_sent = Enum.map(sent, fn x -> x + 1 end)
          listen(beb_pid, max_broadcasts - 1, self_index, new_sent, received)
        end
    end
  end

  defp listen(beb_pid, max_broadcasts, self_index, sent, received) do
    receive do
      { :beb_deliver, sender_index } ->
        # Received a message from downstream
        new_received = List.update_at(received, sender_index, fn x -> x + 1 end)
        # listen again
        listen(beb_pid, max_broadcasts, self_index, sent, new_received)
      { :timeout } -> print_message("Peer #{self_index}:", sent, received, 0)
    after
      0 -> broadcast(beb_pid, max_broadcasts, self_index, sent, received)
    end
  end
end
