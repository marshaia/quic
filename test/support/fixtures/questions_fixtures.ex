defmodule Quic.QuestionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Quic.Questions` context.
  """

  @doc """
  Generate a question.
  """
  def question_fixture(attrs \\ %{}) do
    {:ok, question} =
      attrs
      |> Enum.into(%{
        description: "some description",
        points: 42,
        title: "some title"
      })
      |> Quic.Questions.create_question()

    question
  end

  @doc """
  Generate a question_answer.
  """
  def question_answer_fixture(attrs \\ %{}) do
    {:ok, question_answer} =
      attrs
      |> Enum.into(%{
        answer: "some answer",
        is_correct: true
      })
      |> Quic.Questions.create_question_answer()

    question_answer
  end
end
