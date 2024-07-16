defmodule Quic.Mailer do
  use Swoosh.Mailer, otp_app: :quic

  def domain(), do: "admin.quic" # replace with your own domain name
end
