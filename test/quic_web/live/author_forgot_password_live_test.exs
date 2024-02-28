defmodule QuicWeb.AuthorForgotPasswordLiveTest do
  use QuicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Quic.AccountsFixtures

  alias Quic.Accounts
  alias Quic.Repo

  describe "Forgot password page" do
    test "renders email page", %{conn: conn} do
      {:ok, lv, html} = live(conn, ~p"/authors/reset_password")

      assert html =~ "Forgot your password?"
      assert has_element?(lv, ~s|a[href="#{~p"/authors/register"}"]|, "Register")
      assert has_element?(lv, ~s|a[href="#{~p"/authors/log_in"}"]|, "Log in")
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_author(author_fixture())
        |> live(~p"/authors/reset_password")
        |> follow_redirect(conn, ~p"/")

      assert {:ok, _conn} = result
    end
  end

  describe "Reset link" do
    setup do
      %{author: author_fixture()}
    end

    test "sends a new reset password token", %{conn: conn, author: author} do
      {:ok, lv, _html} = live(conn, ~p"/authors/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", author: %{"email" => author.email})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"

      assert Repo.get_by!(Accounts.AuthorToken, author_id: author.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/authors/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", author: %{"email" => "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"
      assert Repo.all(Accounts.AuthorToken) == []
    end
  end
end
