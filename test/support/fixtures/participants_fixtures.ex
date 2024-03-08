defmodule Quic.ParticipantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Quic.Participants` context.
  """

  @doc """
  Generate a participant.
  """
  def participant_fixture(attrs \\ %{}) do
    {:ok, participant} =
      attrs
      |> Enum.into(%{
        current_question: 42,
        name: "some name",
        total_points: 42
      })
      |> Quic.Participants.create_participant()

    participant
  end
end
