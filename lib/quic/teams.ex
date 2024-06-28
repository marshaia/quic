defmodule Quic.Teams do
  @moduledoc """
  The Teams context.
  """

  import Ecto.Query, warn: false

  alias Quic.Repo
  alias Quic.Accounts.Author
  alias Quic.Teams.Team

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%Team{}, ...]

  """
  def list_all_teams do
    Repo.all(Team)
  end


  def list_all_author_teams(id) do
    author = Repo.get(Author, id) |> Repo.preload([teams: from(t in Team, order_by: [desc: t.inserted_at])]) |>Repo.preload(teams: :authors)
    author.teams
  end




  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id), do: Repo.get!(Team, id) |> Repo.preload(:authors) |> Repo.preload(:quizzes)

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  def create_team_with_author(attrs \\ %{}, id) do
    author = Repo.get(Author, id)

    %Team{}
    |> Team.changeset(attrs, author)
    |> Repo.insert()
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end


  def insert_author_in_team(team \\ %Team{}, username) do
    author = Quic.Accounts.get_author_by_username(username)

    team
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:authors, [author | team.authors])
    |> Repo.update()
  end

  def insert_quiz_in_team(team \\ %Team{}, quiz_id) do
    quiz = Quic.Quizzes.get_quiz!(quiz_id)

    team
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:quizzes, [quiz | team.quizzes])
    |> Repo.update()
  end


  def remove_author_from_team(team_id, author_id) do
    team_bin = Ecto.UUID.dump!(team_id)
    author_bin = Ecto.UUID.dump!(author_id)

    Repo.delete_all(
      from r in "teams_authors",
      where: r.team_id == ^team_bin and r.author_id == ^author_bin
    )
  end

  def remove_quiz_from_team(team_id, quiz_id) do
    team_bin = Ecto.UUID.dump!(team_id)
    quiz_bin = Ecto.UUID.dump!(quiz_id)

    Repo.delete_all(
      from r in "teams_quizzes",
      where: r.team_id == ^team_bin and r.quiz_id == ^quiz_bin
    )
  end

  def is_author_allowed_in_team(team_id, author_id) do
    team_bin = Ecto.UUID.dump!(team_id)
    author_bin = Ecto.UUID.dump!(author_id)

    query = from r in "teams_authors", where: r.team_id == ^team_bin and r.author_id == ^author_bin

    Repo.exists?(query)
  end


  def check_empty_team(team_id) do
    team = get_team!(team_id)
    if Enum.count(team.authors) === 0, do: delete_team(team)
  end

  @doc """
  Deletes a team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{data: %Team{}}

  """
  def change_team(%Team{} = team, attrs \\ %{}) do
    Team.changeset(team, attrs)
  end
end
