# Daniel Yung (lty16)  Tim Green (tpg16)

defmodule Peer do

  def start(index) do
    # need a list of sent count sent[0] = number of messages sent to peers[0]
    # need a list of received count[0
    sent = [0,0,0,0,0]
    received = [0,0,0,0,0]

    receive do
      { :peers, peers } -> listen(peers, index, sent, received, 0)
    end
  end

  defp print_message(sent, received, index) do
    IO.puts "Peers#{index}:{#{inspect Enum.at(sent, 0)}, #{inspect Enum.at(received, 0)}},{#{inspect Enum.at(sent, 1)}, #{inspect Enum.at(received, 1)}},{#{inspect Enum.at(sent, 2)}, #{inspect Enum.at(received, 2)}},{#{inspect Enum.at(sent, 3)}, #{inspect Enum.at(received, 3)}},{#{inspect Enum.at(sent, 4)}, #{inspect Enum.at(received, 4)}}"
  end

  defp listen(peers, index, sent, received, num_completed) do
    pid = self()
    # if num_completed == length(peers) do
    #   print_message(sent, received, index)
    # else
      receive do
        { :broadcast, max_broadcasts } ->
          broadcast(peers, max_broadcasts, index, pid)
          listen(peers, index, sent, received, num_completed)
        { :received, sender_index } ->
          new_received = List.update_at(received, sender_index, fn x -> x + 1 end)
          listen(peers, index, sent, new_received, num_completed)
        { :sent, recipient_index } ->
          new_sent = List.update_at(sent, recipient_index, fn x -> x + 1 end)
          listen(peers, index, new_sent, received, num_completed)
        { :timeout } -> print_message(sent, received, index)
        # { :done } -> listen(peers, index, sent, received, num_completed + 1) #should be 5 sender
      end
    # end
  end

  defp broadcast(peers, max_broadcasts, index, pid) do
    Enum.map(0..4, fn recipient_index -> spawn(Sender, :start, [pid, Enum.at(peers, recipient_index), index, recipient_index, max_broadcasts]) end)
  end
end
