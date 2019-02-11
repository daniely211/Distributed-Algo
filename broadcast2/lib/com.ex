# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Com do
  # Coms only job is to repeatedly tell PL to send messages to other PLs

  # wait for a bind message for the pl
  def start(index, num_peers) do
    receive do
      { :pl_com_bind, pl_pid } -> listen_instruction(pl_pid, num_peers, index)
    end
  end

  # wait for a broadcast message
  def listen_instruction(pl_pid, num_peers, index) do
    sent = List.duplicate(0, num_peers)
    received = List.duplicate(0, num_peers)

    receive do
      { :broadcast, max_broadcasts, timeout } ->
        Process.send_after(self(), { :timeout }, timeout)
        broadcast(num_peers, pl_pid, max_broadcasts, index, sent, received)
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

  # send broadcast messages to PL
  defp broadcast(num_peers, pl_pid, max_broadcasts, self_index, sent, received) do
    receive do
      { :timeout } -> print_message("Peer #{self_index}:", sent, received, 0)
    after
      0 ->
        if max_broadcasts <= 0 do
          # if broadcasting finished, just listen for new messages
          listen(num_peers, pl_pid, max_broadcasts, self_index, sent, received)
        else
          Enum.map(0..num_peers - 1, fn index -> send pl_pid, { :pl_send, index } end)
          new_sent = Enum.map(sent, fn x -> x + 1 end)
          listen(num_peers, pl_pid, max_broadcasts - 1, self_index, new_sent, received)
        end
    end
  end

  # listen for timeout and
  defp listen(num_peers, pl_pid, max_broadcasts, self_index, sent, received) do
    receive do
      { :received, sender_index } ->
        # Received a message from sender
        new_received = List.update_at(received, sender_index, fn x -> x + 1 end)
        broadcast(num_peers, pl_pid, max_broadcasts, self_index, sent, new_received)
      { :timeout } -> print_message("Peer #{self_index}:", sent, received, 0)
    after
      0 -> broadcast(num_peers, pl_pid, max_broadcasts, self_index, sent, received)
    end
  end
end
