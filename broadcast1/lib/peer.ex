# Daniel Yung (lty16)  Tim Green (tpg16)

defmodule Peer do

  def start(index, num_peers) do
    sent = List.duplicate(0, num_peers)
    received = List.duplicate(0, num_peers)

    receive do
      { :peers, peers } -> listen(peers, index, sent, received, 0)
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
    # IO.puts "Peers#{index}:{#{inspect Enum.at(sent, 0)}, #{inspect Enum.at(received, 0)}},{#{inspect Enum.at(sent, 1)}, #{inspect Enum.at(received, 1)}},{#{inspect Enum.at(sent, 2)}, #{inspect Enum.at(received, 2)}},{#{inspect Enum.at(sent, 3)}, #{inspect Enum.at(received, 3)}},{#{inspect Enum.at(sent, 4)}, #{inspect Enum.at(received, 4)}}"
  end

  defp listen(peers, index, sent, received, num_completed) do
    pid = self()
    # if num_completed == length(peers) do
    #   print_message(sent, received, index)
    # else
      receive do
        { :broadcast, max_broadcasts, timeout } ->
          broadcast(peers, max_broadcasts, index, pid)
          Process.send_after(self(), {:timeout}, timeout)
          listen(peers, index, sent, received, num_completed)
        { :received, sender_index } ->
          # Received a message from sender
          new_received = List.update_at(received, sender_index, fn x -> x + 1 end)
          listen(peers, index, sent, new_received, num_completed)
        { :sent, recipient_index } ->
          # Acknowledged a sent
          new_sent = List.update_at(sent, recipient_index, fn x -> x + 1 end)
          listen(peers, index, new_sent, received, num_completed)
        { :timeout } -> print_message("Peers #{index}:", sent, received, 0)
        # { :done } -> listen(peers, index, sent, received, num_completed + 1) #should be 5 sender
      end
    # end
  end

  defp broadcast(peers, max_broadcasts, index, pid) do
    n = length(peers) - 1 
    Enum.map(0..n, fn recipient_index -> spawn(Sender, :start, [pid, Enum.at(peers, recipient_index), index, recipient_index, max_broadcasts]) end)
  end
end
