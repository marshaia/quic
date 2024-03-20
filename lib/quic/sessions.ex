defmodule Quic.Sessions do
  @moduledoc """
  The Sessions context.
  """

  import Ecto.Query, warn: false
  alias Quic.Repo

  alias Quic.Accounts.Author
  alias Quic.Sessions.Session

  alias Quic.Sessions.CodeGenerator

  @doc """
  Returns the list of sessions.

  ## Examples

      iex> list_sessions()
      [%Session{}, ...]

  """
  def list_sessions do
    Repo.all(Session)
  end

  def list_all_author_sessions(id) do
    author = Repo.get(Author, id) |> Repo.preload(:sessions)
    author.sessions
  end

  @doc """
  Gets a single session.

  Raises `Ecto.NoResultsError` if the Session does not exist.

  ## Examples

      iex> get_session!(123)
      %Session{}

      iex> get_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_session!(id), do: Repo.get!(Session, id) |> Repo.preload(:monitor) |> Repo.preload(:quiz) |> Repo.preload(:participants)

  def get_session_by_code(code) do
    Repo.get_by(Session, code: code) |> Repo.preload(:monitor) |> Repo.preload(:quiz) |> Repo.preload(:participants)
  end

  def get_open_sessions() do
    Repo.get_by(Session, status: :open)
  end


  @doc """
  Creates a session.

  ## Examples

      iex> create_session(%{field: value})
      {:ok, %Session{}}

      iex> create_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_session(attrs \\ %{}) do
    random_code = generate_valid_code()

    attrs = Map.put(attrs, "code", random_code)
          |> Map.put("status", :open)
          |> Map.put("start_date", DateTime.utc_now())

    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end

  def generate_valid_code() do
    code = CodeGenerator.generate_code(5)

    case get_open_sessions() do
      nil -> code
      sessions ->
        if Enum.any?(sessions, fn session -> session.code === code end) do
          generate_valid_code()
        else
          code
        end
    end

  end

  @doc """
  Updates a session.

  ## Examples

      iex> update_session(session, %{field: new_value})
      {:ok, %Session{}}

      iex> update_session(session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_session(%Session{} = session, attrs) do
    session
    |> Session.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a session.

  ## Examples

      iex> delete_session(session)
      {:ok, %Session{}}

      iex> delete_session(session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking session changes.

  ## Examples

      iex> change_session(session)
      %Ecto.Changeset{data: %Session{}}

  """
  def change_session(%Session{} = session, attrs \\ %{}) do
    Session.changeset(session, attrs)
  end
end
