defmodule MessageAgent do
  def start_link do
    Agent.start_link fn -> %{id: 0, msgs: MapSet.new} end
  end

  def next_id(pid) do
    :ok = Agent.update pid, fn %{id: id} = map ->
      Map.put(map, :id, id + 1)
    end

    MessageAgent.get_id(pid)
  end

  def get_id(pid) do
    id = Agent.get(pid, fn map -> map.id end)

    deterministic_hash_id(id)
  end

  def get_msgs(pid) do
    Agent.get(pid, fn map -> map.msgs end)
  end

  def new_msg?(pid, %{id: id}) do
    msgs = MessageAgent.get_msgs(pid)
    not MapSet.member?(msgs, id)
  end

  def put_msg(pid, %{id: id}) do
    Agent.update pid, fn %{msgs: msgs} = map ->
      new_mapset = MapSet.put(msgs, id)
      Map.put(map, :msgs, new_mapset)
    end
  end

  def deterministic_hash_id(id) do
    msg_id = id |> to_string
    beam_ref = self() |> inspect
    machine_ref = :os.getpid() |> to_string
    global_ref = Inet.active_mac_addr()

    msg_ref = msg_id <> beam_ref <> machine_ref <> global_ref
    :crypto.hash(:sha256, msg_ref) |> Base.encode16
  end
end