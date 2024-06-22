defmodule Quic.ParametersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Quic.Parameters` context.
  """

  @doc """
  Generate a parameter.
  """
  def parameter_fixture(attrs \\ %{}) do
    {:ok, parameter} =
      attrs
      |> Enum.into(%{
        code: "some code",
        correct_answers: %{},
        language: :c,
        tests: []
      })
      |> Quic.Parameters.create_parameter()

    parameter
  end
end
