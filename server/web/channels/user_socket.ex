defmodule Berkeley.UserSocket do
  use Phoenix.Socket

  alias Berkeley.Accounts

  channel("room:*", Berkeley.RoomChannel)
  channel("chat:*", Berkeley.ChatChannel)

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    token = Base.url_decode64!(token, padding: false)

    case Accounts.find_by_session_token(token) do
      nil ->
        :error

      user ->
        user = Accounts.update_last_seen(user)
        {:ok, assign(socket, :user, user)}
    end
  end

  # @impl true
  # def connect(_params, socket, _connect_info), do: :error

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Berkeley.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(_socket), do: nil
end
