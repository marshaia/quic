defmodule QuicWeb.AuthorSessionControllerTest do
  use QuicWeb.ConnCase, async: true

  import Quic.AccountsFixtures

  setup do
    %{author: author_fixture()}
  end

  describe "POST /authors/log_in" do
    test "logs the author in", %{conn: conn, author: author} do
      conn =
        post(conn, ~p"/authors/log_in", %{
          "author" => %{"email" => author.email, "password" => valid_author_password()}
        })

      assert get_session(conn, :author_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ author.email
      assert response =~ ~p"/authors/settings"
      assert response =~ ~p"/authors/log_out"
    end

    test "logs the author in with remember me", %{conn: conn, author: author} do
      conn =
        post(conn, ~p"/authors/log_in", %{
          "author" => %{
            "email" => author.email,
            "password" => valid_author_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_quic_web_author_remember_me"]
      assert redirected_to(conn) == ~p"/"
    end

    test "logs the author in with return to", %{conn: conn, author: author} do
      conn =
        conn
        |> init_test_session(author_return_to: "/foo/bar")
        |> post(~p"/authors/log_in", %{
          "author" => %{
            "email" => author.email,
            "password" => valid_author_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "login following registration", %{conn: conn, author: author} do
      conn =
        conn
        |> post(~p"/authors/log_in", %{
          "_action" => "registered",
          "author" => %{
            "email" => author.email,
            "password" => valid_author_password()
          }
        })

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Account created successfully"
    end

    test "login following password update", %{conn: conn, author: author} do
      conn =
        conn
        |> post(~p"/authors/log_in", %{
          "_action" => "password_updated",
          "author" => %{
            "email" => author.email,
            "password" => valid_author_password()
          }
        })

      assert redirected_to(conn) == ~p"/authors/settings"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password updated successfully"
    end

    test "redirects to login page with invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/authors/log_in", %{
          "author" => %{"email" => "invalid@email.com", "password" => "invalid_password"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
      assert redirected_to(conn) == ~p"/authors/log_in"
    end
  end

  describe "DELETE /authors/log_out" do
    test "logs the author out", %{conn: conn, author: author} do
      conn = conn |> log_in_author(author) |> delete(~p"/authors/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :author_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the author is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/authors/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :author_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
