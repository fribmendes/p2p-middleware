defmodule Ring.ServerTest do
  use ExUnit.Case
  use Ring.TCPSocketCase

  describe "listen/2" do
    test "notifies of an incoming connection" do
      pid = self()
      Task.start fn -> Ring.Server.listen(pid, 3000) end
      connect_to_tcp_socket(3000)

      assert_receive {:"$gen_cast", {:accept, _socket}}
    end
  end
end
