defmodule Quic.Repo do
  use Ecto.Repo,
    otp_app: :quic,
    adapter: Ecto.Adapters.Postgres
end
