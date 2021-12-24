defmodule ChatWeb.RoomState do
  use GenServer
  require Logger

  # client side
  def start_link() do
    # should also add player info, player count?
    # Remove a player from state once he leaves?
    messages = []
    GenServer.start_link(__MODULE__, { messages }, name: RoomState)
  end

  def get_rooms() do
    GenServer.call(RoomState, :get_rooms)
  end

  def remove_room(room) do
    GenServer.call(RoomState, {:remove_room, room})
  end

  def put_room(room) do
    GenServer.cast(RoomState, {:put_room, room})
  end

  # server side
  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:put_room, room}, { messages }) do
    messages = messages ++ [room]
    {:noreply, { messages }}
  end

  @impl true
  def handle_call(:get_rooms, _from, { messages } = state) do
    {:reply, messages, state}
  end

  @impl true
  def handle_call({:remove_room, room}, _from, { messages }) do
    updated_messages = messages
      |> Enum.filter(
        fn s_room ->
          s_room !== room
        end
      )

      {:reply, {:ok, "removed successfully"}, { updated_messages }}
  end
end
