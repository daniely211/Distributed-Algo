# Daniel Yung (lty16)  Tim Green (tpg16)

defmodule Peer do


  def start() do
    receive do
    { :peers, peers } -> listen(peers)
    end
  end

  defp listen(peers) do
    # pid = self()
    receive do
    {:broadcast, max_broadcasts, timeout}  ->
      broadcast(peers, max_broadcasts-1)
    end
  end

  defp broadcast(peers, index) do
  
  end


end # module -----------------------

