defmodule Quic.ParticipantAnswersTest do
  use Quic.DataCase

  alias Quic.ParticipantAnswers

  describe "participant_answers" do
    alias Quic.ParticipantAnswers.ParticipantAnswer

    import Quic.ParticipantAnswersFixtures

    @invalid_attrs %{result: nil, answer: nil}

    test "list_participant_answers/0 returns all participant_answers" do
      participant_answer = participant_answer_fixture()
      assert ParticipantAnswers.list_participant_answers() == [participant_answer]
    end

    test "get_participant_answer!/1 returns the participant_answer with given id" do
      participant_answer = participant_answer_fixture()
      assert ParticipantAnswers.get_participant_answer!(participant_answer.id) == participant_answer
    end

    test "create_participant_answer/1 with valid data creates a participant_answer" do
      valid_attrs = %{result: :correct, answer: "some answer"}

      assert {:ok, %ParticipantAnswer{} = participant_answer} = ParticipantAnswers.create_participant_answer(valid_attrs)
      assert participant_answer.result == :correct
      assert participant_answer.answer == "some answer"
    end

    test "create_participant_answer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ParticipantAnswers.create_participant_answer(@invalid_attrs)
    end

    test "update_participant_answer/2 with valid data updates the participant_answer" do
      participant_answer = participant_answer_fixture()
      update_attrs = %{result: :incorrect, answer: "some updated answer"}

      assert {:ok, %ParticipantAnswer{} = participant_answer} = ParticipantAnswers.update_participant_answer(participant_answer, update_attrs)
      assert participant_answer.result == :incorrect
      assert participant_answer.answer == "some updated answer"
    end

    test "update_participant_answer/2 with invalid data returns error changeset" do
      participant_answer = participant_answer_fixture()
      assert {:error, %Ecto.Changeset{}} = ParticipantAnswers.update_participant_answer(participant_answer, @invalid_attrs)
      assert participant_answer == ParticipantAnswers.get_participant_answer!(participant_answer.id)
    end

    test "delete_participant_answer/1 deletes the participant_answer" do
      participant_answer = participant_answer_fixture()
      assert {:ok, %ParticipantAnswer{}} = ParticipantAnswers.delete_participant_answer(participant_answer)
      assert_raise Ecto.NoResultsError, fn -> ParticipantAnswers.get_participant_answer!(participant_answer.id) end
    end

    test "change_participant_answer/1 returns a participant_answer changeset" do
      participant_answer = participant_answer_fixture()
      assert %Ecto.Changeset{} = ParticipantAnswers.change_participant_answer(participant_answer)
    end
  end
end
