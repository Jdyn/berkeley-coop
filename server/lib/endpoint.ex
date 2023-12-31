defmodule Berkeley.Endpoint do
  use Phoenix.Endpoint, otp_app: :berkeley

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "session_id",
    signing_salt: "AwA3CM4V",
    same_site: "none",
    secure: true
  ]

  plug(CORSPlug, origin: ["http://localhost:3000", "https://berkeley.vercel.app"])

  socket("/socket", Berkeley.UserSocket,
    websocket: true,
    longpoll: false,
    check_origin: ["https://berkeley.vercel.app", "http://localhost:3000"]
  )

  # socket("/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]])

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug(Phoenix.CodeReloader)
    plug(Phoenix.Ecto.CheckRepoStatus, otp_app: :berkeley)
  end

  # plug(Phoenix.LiveDashboard.RequestLogger,
  #   param_key: "request_logger",
  #   cookie_key: "request_logger"
  # )

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)
  plug(Berkeley.Router)
end
