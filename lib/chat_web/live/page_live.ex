defmodule ChatWeb.PageLive do
  use ChatWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    # initializing phoenix pub sub
    Phoenix.PubSub.subscribe(Chat.PubSub, "chat-rooms")

    # starting RoomState Genserver
    ChatWeb.RoomState.start_link()

    #Getting the rooms from RoomState
    rooms = ChatWeb.RoomState.get_rooms()

    {:ok,
      assign(
        socket,
        rooms: rooms
      )
    }
  end

  @impl true
  def handle_event("random-room",_params, socket) do
    #Generate a random slug path
    random_slug = MnemonicSlugs.generate_slug(4)
    path = "/chat/" <> random_slug

    # Adding room to the RoomState
    ChatWeb.RoomState.put_room(random_slug)

    # broadcasting to chat-room pubsub
    broadcast_payload = random_slug

    Phoenix.PubSub.broadcast!(Chat.PubSub,"chat-rooms", broadcast_payload)

    #Redirect the user to random_slug path
    {:noreply, push_redirect(socket, to: path)}
  end

  @impl true
  def handle_event("join-room", %{ "value" => url}, socket) do
    room_url = "/chat/#{url}"
    {:noreply, push_redirect(socket, to: room_url)}
  end

  @impl true
  def handle_info(room, socket) do
    rooms = socket.assigns.rooms ++ [room]
    {:noreply, assign(socket, rooms: rooms)}
  end
end
