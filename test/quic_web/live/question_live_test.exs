defmodule QuicWeb.QuestionLiveTest do
  use QuicWeb.ConnCase

  import Phoenix.LiveViewTest
  import Quic.QuestionsFixtures

  @create_attrs %{description: "some description", title: "some title", points: 42}
  @update_attrs %{description: "some updated description", title: "some updated title", points: 43}
  @invalid_attrs %{description: nil, title: nil, points: nil}

  defp create_question(_) do
    question = question_fixture()
    %{question: question}
  end

  describe "Index" do
    setup [:create_question]

    test "lists all questions", %{conn: conn, question: question} do
      {:ok, _index_live, html} = live(conn, ~p"/questions")

      assert html =~ "Listing Questions"
      assert html =~ question.description
    end

    test "saves new question", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/questions")

      assert index_live |> element("a", "New Question") |> render_click() =~
               "New Question"

      assert_patch(index_live, ~p"/questions/new")

      assert index_live
             |> form("#question-form", question: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#question-form", question: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/questions")

      html = render(index_live)
      assert html =~ "Question created successfully"
      assert html =~ "some description"
    end

    test "updates question in listing", %{conn: conn, question: question} do
      {:ok, index_live, _html} = live(conn, ~p"/questions")

      assert index_live |> element("#questions-#{question.id} a", "Edit") |> render_click() =~
               "Edit Question"

      assert_patch(index_live, ~p"/questions/#{question}/edit")

      assert index_live
             |> form("#question-form", question: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#question-form", question: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/questions")

      html = render(index_live)
      assert html =~ "Question updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes question in listing", %{conn: conn, question: question} do
      {:ok, index_live, _html} = live(conn, ~p"/questions")

      assert index_live |> element("#questions-#{question.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#questions-#{question.id}")
    end
  end

  describe "Show" do
    setup [:create_question]

    test "displays question", %{conn: conn, question: question} do
      {:ok, _show_live, html} = live(conn, ~p"/questions/#{question}")

      assert html =~ "Show Question"
      assert html =~ question.description
    end

    test "updates question within modal", %{conn: conn, question: question} do
      {:ok, show_live, _html} = live(conn, ~p"/questions/#{question}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Question"

      assert_patch(show_live, ~p"/questions/#{question}/show/edit")

      assert show_live
             |> form("#question-form", question: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#question-form", question: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/questions/#{question}")

      html = render(show_live)
      assert html =~ "Question updated successfully"
      assert html =~ "some updated description"
    end
  end
end
