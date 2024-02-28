defmodule QuicWeb.AuthorConfirmationLiveTest do
  use QuicWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Quic.AccountsFixtures

  alias Quic.Accounts
  alias Quic.Repo

  setup do
    %{author: author_fixture()}
  end

  describe "Confirm author" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/authors/confirm/some-token")
      assert html =~ "Confirm Account"
    end

    test "confirms the given token once", %{conn: conn, author: author} do
      token =
        extract_author_token(fn url ->
          Accounts.deliver_author_confirmation_instructions(author, url)
        end)

      {:ok, lv, _html} = live(conn, ~p"/authors/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Author confirmed successfully"

      assert Accounts.get_author!(author.id).confirmed_at
      refute get_session(conn, :author_token)
      assert Repo.all(Accounts.AuthorToken) == []

      # when not logged in
      {:ok, lv, _html} = live(conn, ~p"/authors/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Author confirmation link is invalid or it has expired"

      # when logged in
      conn =
        build_conn()
        |> log_in_author(author)

      {:ok, lv, _html} = live(conn, ~p"/authors/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result
      refute Phoenix.Flash.get(conn.assigns.flash, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, author: author} do
      {:ok, lv, _html} = live(conn, ~p"/authors/confirm/invalid-token")

      {:ok, conn} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Author confirmation link is invalid or it has expired"

      refute Accounts.get_author!(author.id).confirmed_at
    end
  end
end
