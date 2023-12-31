defmodule Berkeley.Router do
  use Berkeley.Web, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:fetch_session)
    plug(:put_secure_browser_headers)
  end

  pipeline :ensure_auth do
    plug(Berkeley.Auth.FetchUser)
    plug(Berkeley.Auth.EnsureAuth)
  end

  # if Mix.env() == :dev do
  #   forward("/mailbox", Plug.Swoosh.MailboxPreview)
  # end

  scope "/api", Berkeley do
    pipe_through(:api)
    get("/houses", HouseController, :index)
    get("/seed", HouseController, :seed)

    resources("/account", UserController, singleton: true, only: []) do
      post("/signup", UserController, :sign_up)
      post("/signin", UserController, :sign_in)
      get("/:provider/request", UserController, :provider_request)
      get("/:provider/callback", UserController, :provider_callback)
    end
  end

  scope "/api", Berkeley do
    pipe_through([:api, :ensure_auth])

    resources("/events", EventController)
    get("/account/events", EventController, :user_index)
    post("/rooms", RoomController, :create)
    post("/account/update", UserController, :update)

    resources("/account", UserController, singleton: true, only: [:show]) do
      get("/sessions", UserController, :show_sessions)
      get("/email/confirm", UserController, :send_user_email_confirmation)
      post("/email/confirm/:token", UserController, :do_user_email_confirmation)
      delete("/sessions/clear", UserController, :delete_sessions)
      delete("/sessions/:tracking_id", UserController, :delete_session)
      delete("/signout", UserController, :sign_out)
    end
  end
end
