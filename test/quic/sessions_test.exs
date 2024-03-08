defmodule Quic.SessionsTest do
  use Quic.DataCase

  alias Quic.Sessions

  describe "sessions" do
    alias Quic.Sessions.Session

    import Quic.SessionsFixtures

    @invalid_attrs %{code: nil, status: nil, type: nil, start_date: nil, end_date: nil}

    test "list_sessions/0 returns all sessions" do
      session = session_fixture()
      assert Sessions.list_sessions() == [session]
    end

    test "get_session!/1 returns the session with given id" do
      session = session_fixture()
      assert Sessions.get_session!(session.id) == session
    end

    test "create_session/1 with valid data creates a session" do
      valid_attrs = %{code: "some code", status: :live, type: :teacher_paced, start_date: ~D[2024-03-07], end_date: ~D[2024-03-07]}

      assert {:ok, %Session{} = session} = Sessions.create_session(valid_attrs)
      assert session.code == "some code"
      assert session.status == :live
      assert session.type == :teacher_paced
      assert session.start_date == ~D[2024-03-07]
      assert session.end_date == ~D[2024-03-07]
    end

    test "create_session/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sessions.create_session(@invalid_attrs)
    end

    test "update_session/2 with valid data updates the session" do
      session = session_fixture()
      update_attrs = %{code: "some updated code", status: :closed, type: :student_paced, start_date: ~D[2024-03-08], end_date: ~D[2024-03-08]}

      assert {:ok, %Session{} = session} = Sessions.update_session(session, update_attrs)
      assert session.code == "some updated code"
      assert session.status == :closed
      assert session.type == :student_paced
      assert session.start_date == ~D[2024-03-08]
      assert session.end_date == ~D[2024-03-08]
    end

    test "update_session/2 with invalid data returns error changeset" do
      session = session_fixture()
      assert {:error, %Ecto.Changeset{}} = Sessions.update_session(session, @invalid_attrs)
      assert session == Sessions.get_session!(session.id)
    end

    test "delete_session/1 deletes the session" do
      session = session_fixture()
      assert {:ok, %Session{}} = Sessions.delete_session(session)
      assert_raise Ecto.NoResultsError, fn -> Sessions.get_session!(session.id) end
    end

    test "change_session/1 returns a session changeset" do
      session = session_fixture()
      assert %Ecto.Changeset{} = Sessions.change_session(session)
    end
  end
end
