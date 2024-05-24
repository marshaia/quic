defmodule Quic.ParticipantAnswersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Quic.ParticipantAnswers` context.
  """

  @doc """
  Generate a participant_answer.
  """
  def participant_answer_fixture(attrs \\ %{}) do
    {:ok, participant_answer} =
      attrs
      |> Enum.into(%{
        answer: "some answer",
        result: :correct
      })
      |> Quic.ParticipantAnswers.create_participant_answer()

    participant_answer
  end
end
