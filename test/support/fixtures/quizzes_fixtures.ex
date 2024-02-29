defmodule Quic.QuizzesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Quic.Quizzes` context.
  """

  @doc """
  Generate a quiz.
  """
  def quiz_fixture(attrs \\ %{}) do
    {:ok, quiz} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name",
        total_points: 42
      })
      |> Quic.Quizzes.create_quiz()

    quiz
  end
end
