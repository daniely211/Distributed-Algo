# Daniel Yung (lty16)  Tim Green (tpg16)

defmodule Peer do

  def start(index) do
    receive do
      { :peers, peers } -> listen_broadcast(peers, index)
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

  defp listen_broadcast(peers, index) do
    num_peers = length(peers)
    sent = List.duplicate(0, num_peers)
    received = List.duplicate(0, num_peers)

    receive do
      { :broadcast, max_broadcasts, timeout } ->
        Process.send_after(self(), { :timeout }, timeout)
        broadcast(peers, max_broadcasts, index, sent, received)
    end
  end

  defp broadcast(peers, max_broadcasts, self_index, sent, received) do
    receive do
      { :timeout } -> print_message("Peer #{self_index}:", sent, received, 0)
    after
      0 ->
        if max_broadcasts <= 0 do
          listen(peers, max_broadcasts, self_index, sent, received)
        else
          Enum.map(peers, fn pid -> send pid, { :received, self_index } end)
          new_sent = Enum.map(sent, fn x -> x + 1 end)
          listen(peers, max_broadcasts - 1, self_index, new_sent, received)
        end
    end
  end

  defp listen(peers, max_broadcasts, self_index, sent, received) do
    receive do
      { :received, sender_index } ->
        # Received a message from sender
        new_received = List.update_at(received, sender_index, fn x -> x + 1 end)
        broadcast(peers, max_broadcasts, self_index, sent, new_received)
      { :timeout } -> print_message("Peer #{self_index}:", sent, received, 0)
    after
      0 -> broadcast(peers, max_broadcasts, self_index, sent, received)
    end
  end
end
