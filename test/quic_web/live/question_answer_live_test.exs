defmodule QuicWeb.QuestionAnswerLiveTest do
  use QuicWeb.ConnCase

  import Phoenix.LiveViewTest
  import Quic.QuestionsFixtures

  @create_attrs %{answer: "some answer", is_correct: true}
  @update_attrs %{answer: "some updated answer", is_correct: false}
  @invalid_attrs %{answer: nil, is_correct: false}

  defp create_question_answer(_) do
    question_answer = question_answer_fixture()
    %{question_answer: question_answer}
  end

  describe "Index" do
    setup [:create_question_answer]

    test "lists all question_answers", %{conn: conn, question_answer: question_answer} do
      {:ok, _index_live, html} = live(conn, ~p"/question_answers")

      assert html =~ "Listing Question answers"
      assert html =~ question_answer.answer
    end

    test "saves new question_answer", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/question_answers")

      assert index_live |> element("a", "New Question answer") |> render_click() =~
               "New Question answer"

      assert_patch(index_live, ~p"/question_answers/new")

      assert index_live
             |> form("#question_answer-form", question_answer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#question_answer-form", question_answer: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/question_answers")

      html = render(index_live)
      assert html =~ "Question answer created successfully"
      assert html =~ "some answer"
    end

    test "updates question_answer in listing", %{conn: conn, question_answer: question_answer} do
      {:ok, index_live, _html} = live(conn, ~p"/question_answers")

      assert index_live |> element("#question_answers-#{question_answer.id} a", "Edit") |> render_click() =~
               "Edit Question answer"

      assert_patch(index_live, ~p"/question_answers/#{question_answer}/edit")

      assert index_live
             |> form("#question_answer-form", question_answer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#question_answer-form", question_answer: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/question_answers")

      html = render(index_live)
      assert html =~ "Question answer updated successfully"
      assert html =~ "some updated answer"
    end

    test "deletes question_answer in listing", %{conn: conn, question_answer: question_answer} do
      {:ok, index_live, _html} = live(conn, ~p"/question_answers")

      assert index_live |> element("#question_answers-#{question_answer.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#question_answers-#{question_answer.id}")
    end
  end

  describe "Show" do
    setup [:create_question_answer]

    test "displays question_answer", %{conn: conn, question_answer: question_answer} do
      {:ok, _show_live, html} = live(conn, ~p"/question_answers/#{question_answer}")

      assert html =~ "Show Question answer"
      assert html =~ question_answer.answer
    end

    test "updates question_answer within modal", %{conn: conn, question_answer: question_answer} do
      {:ok, show_live, _html} = live(conn, ~p"/question_answers/#{question_answer}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Question answer"

      assert_patch(show_live, ~p"/question_answers/#{question_answer}/show/edit")

      assert show_live
             |> form("#question_answer-form", question_answer: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#question_answer-form", question_answer: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/question_answers/#{question_answer}")

      html = render(show_live)
      assert html =~ "Question answer updated successfully"
      assert html =~ "some updated answer"
    end
  end
end
