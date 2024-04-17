defmodule Quic.QuestionsTest do
  use Quic.DataCase

  alias Quic.Questions

  describe "questions" do
    alias Quic.Questions.Question

    import Quic.QuestionsFixtures

    @invalid_attrs %{description: nil, title: nil, points: nil}

    test "list_questions/0 returns all questions" do
      question = question_fixture()
      assert Questions.list_questions() == [question]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert Questions.get_question!(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      valid_attrs = %{description: "some description", title: "some title", points: 42}

      assert {:ok, %Question{} = question} = Questions.create_question(valid_attrs)
      assert question.description == "some description"
      assert question.title == "some title"
      assert question.points == 42
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Questions.create_question(@invalid_attrs)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()
      update_attrs = %{description: "some updated description", title: "some updated title", points: 43}

      assert {:ok, %Question{} = question} = Questions.update_question(question, update_attrs)
      assert question.description == "some updated description"
      assert question.title == "some updated title"
      assert question.points == 43
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = Questions.update_question(question, @invalid_attrs)
      assert question == Questions.get_question!(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      assert {:ok, %Question{}} = Questions.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> Questions.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = Questions.change_question(question)
    end
  end

  describe "question_answers" do
    alias Quic.Questions.QuestionAnswer

    import Quic.QuestionsFixtures

    @invalid_attrs %{answer: nil, is_correct: nil}

    test "list_question_answers/0 returns all question_answers" do
      question_answer = question_answer_fixture()
      assert Questions.list_question_answers() == [question_answer]
    end

    test "get_question_answer!/1 returns the question_answer with given id" do
      question_answer = question_answer_fixture()
      assert Questions.get_question_answer!(question_answer.id) == question_answer
    end

    test "create_question_answer/1 with valid data creates a question_answer" do
      valid_attrs = %{answer: "some answer", is_correct: true}

      assert {:ok, %QuestionAnswer{} = question_answer} = Questions.create_question_answer(valid_attrs)
      assert question_answer.answer == "some answer"
      assert question_answer.is_correct == true
    end

    test "create_question_answer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Questions.create_question_answer(@invalid_attrs)
    end

    test "update_question_answer/2 with valid data updates the question_answer" do
      question_answer = question_answer_fixture()
      update_attrs = %{answer: "some updated answer", is_correct: false}

      assert {:ok, %QuestionAnswer{} = question_answer} = Questions.update_question_answer(question_answer, update_attrs)
      assert question_answer.answer == "some updated answer"
      assert question_answer.is_correct == false
    end

    test "update_question_answer/2 with invalid data returns error changeset" do
      question_answer = question_answer_fixture()
      assert {:error, %Ecto.Changeset{}} = Questions.update_question_answer(question_answer, @invalid_attrs)
      assert question_answer == Questions.get_question_answer!(question_answer.id)
    end

    test "delete_question_answer/1 deletes the question_answer" do
      question_answer = question_answer_fixture()
      assert {:ok, %QuestionAnswer{}} = Questions.delete_question_answer(question_answer)
      assert_raise Ecto.NoResultsError, fn -> Questions.get_question_answer!(question_answer.id) end
    end

    test "change_question_answer/1 returns a question_answer changeset" do
      question_answer = question_answer_fixture()
      assert %Ecto.Changeset{} = Questions.change_question_answer(question_answer)
    end
  end
end
