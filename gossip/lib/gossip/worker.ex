defmodule Gossip.Worker do
  use Task

  def start_link(args) do
    Task.start_link(__MODULE__, :recv_loop, args)
  end

  def recv_loop(pid, socket) do
    continue = receive do
      {:tcp, _port, msg} ->
        Gossip.recv(pid, msg)

        Gossip.Logger.info(
          "[WORKER #{inspect self()}]: Received message from #{inspect socket}"
        )

        true

      {:tcp_closed, port} ->
        TCP.close(port)
        Gossip.disconnect(pid, self())

        Gossip.Logger.info(
          "[WORKER #{inspect self()}]: #{inspect socket} disconnected"
        )

        false

      {:send, msg} ->
        TCP.send(socket, msg)

        Gossip.Logger.info(
          "[WORKER #{inspect self()}]: Sent message to #{inspect socket}"
        )
        true

      msg ->
        IO.inspect(msg)

        true
    end

    continue and recv_loop(pid, socket)
  end
end
