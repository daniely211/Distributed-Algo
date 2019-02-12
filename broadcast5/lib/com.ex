# Daniel Yung (lty16)  Tim Green (tpg16)
defmodule Com do
  # Coms only job is to repeatedly tell PL to send messages to other PLs

  def start(self_index, num_peers) do
    sent = List.duplicate(0, num_peers)
    received = List.duplicate(0, num_peers)

    # Wait for a bind message from beb
    receive do
      { :beb_bind, beb_pid } -> listen_instruction(beb_pid, self_index, sent, received)
      { :kill } ->
        print_message("Peer #{self_index}:", sent, received, 0)
        Process.exit(self(), :kill)
    end
  end

  def listen_instruction(beb_pid, self_index, sent, received) do
    receive do
      { :broadcast, max_broadcasts, timeout } ->
        Process.send_after(self(), { :timeout }, timeout)
        broadcast(beb_pid, max_broadcasts, self_index, sent, received)
      { :timeout } -> print_message("Peer #{self_index}:", sent, received, 0)
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

  defp broadcast(beb_pid, max_broadcasts, self_index, sent, received) do
    # broadcast needs to be in a send and receive loop
    receive do
      { :timeout } -> print_message("Peer #{self_index}:", sent, received, 0)
      { :kill } ->
        print_message("Peer #{self_index}:", sent, received, 0)
        Process.exit(self(), :kill)
    after
      0 ->
        if max_broadcasts <= 0 do
          # this case we will keep listening after we are done broadcasting... because we will send more than we listen
          listen(beb_pid, max_broadcasts, self_index, sent, received)
        else
          # Tell Beb to broadcast!
          send beb_pid, { :beb_broadcast }
          # Update the sent list since we send a beb broadcast, we increase sent for all the peers
          new_sent = Enum.map(sent, fn x -> x + 1 end)
          listen(beb_pid, max_broadcasts - 1, self_index, new_sent, received)
        end
    end
  end

  defp listen(beb_pid, max_broadcasts, self_index, sent, received) do
    # listen once, then send another broadcast.
    receive do
      { :beb_deliver, sender_index} ->
        # Received a message from downstream
        new_received = List.update_at(received, sender_index, fn x -> x + 1 end)
        # broadcast again
        broadcast(beb_pid, max_broadcasts, self_index, sent, new_received)
      { :timeout } -> print_message("Peer #{self_index}:", sent, received, 0)
      { :kill } ->
        print_message("Peer #{self_index}:", sent, received, 0)
        Process.exit(self(), :kill)
    after
      0 -> broadcast(beb_pid, max_broadcasts, self_index, sent, received)
    end
  end
end
