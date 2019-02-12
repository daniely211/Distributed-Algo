# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Com do
  # Com only job is to repeatedly tell PL to send msg to other PL.
  def start(self_index, num_peers) do
    sent = List.duplicate(0, num_peers)
    received = List.duplicate(0, num_peers)
    # Wait for a bind message from beb
    receive do
      { :erb_bind, erb_pid } -> listen_instruction(erb_pid, self_index, sent, received)
    end
  end

  def listen_instruction(erb_pid, self_index, sent, received) do
    receive do
      { :broadcast, max_broadcasts, timeout } ->
        Process.send_after(self(), { :timeout },  timeout)
        broadcast(erb_pid, max_broadcasts, self_index, sent, received, 0)
      { :kill } ->
        print_message("Peer #{self_index}:", sent, received, 0)
        Process.exit(self(), :kill)
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

  defp broadcast(erb_pid, max_broadcasts, self_index, sent, received, seq_num) do
    # broadcast needs to be in a send and receive loop
    receive do
      { :timeout } -> print_message("Peer #{self_index}:", sent, received, 0)
      { :kill } ->
        print_message("Peer #{self_index}:", sent, received, 0)
        Process.exit(self(), :kill)
    after 0 ->
      if max_broadcasts <= 0 do
        # this case we will keep listening after we are done broadcasting because we will send more than we listen
        listen(erb_pid, max_broadcasts, self_index, sent, received, seq_num)
      else
        # Tell ERB to broadcast!
        send erb_pid, { :rb_broadcast, self_index, seq_num }
        # Update the sent list since we send a beb broadcast, we increase sent for all the peers
        new_sent = Enum.map(sent, fn x -> x + 1 end)
        listen(erb_pid, max_broadcasts - 1, self_index, new_sent, received, seq_num + 1)
      end
    end
  end

  defp listen(erb_pid, max_broadcasts, self_index, sent, received, seq_num) do
    # listen once, then send another broadcast.
    receive do
      { :rb_deliver, sender_index} ->
        # received a message from downstream
        # IO.puts "COM GOT MESSAGE"
        new_received = List.update_at(received, sender_index, fn x -> x + 1 end)
        # broadcast again
        broadcast(erb_pid, max_broadcasts, self_index, sent, new_received, seq_num)
      { :timeout } -> print_message("Peer #{self_index}:", sent, received, 0)
      { :kill } ->
        print_message("Peer #{self_index}:", sent, received, 0)
        Process.exit(self(), :kill)
    after
      0 -> broadcast(erb_pid, max_broadcasts, self_index, sent, received, seq_num)
    end
  end
end
