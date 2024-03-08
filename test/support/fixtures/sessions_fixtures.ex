defmodule Quic.SessionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Quic.Sessions` context.
  """

  @doc """
  Generate a session.
  """
  def session_fixture(attrs \\ %{}) do
    {:ok, session} =
      attrs
      |> Enum.into(%{
        code: "some code",
        end_date: ~D[2024-03-07],
        start_date: ~D[2024-03-07],
        status: :live,
        type: :teacher_paced
      })
      |> Quic.Sessions.create_session()

    session
  end
end
