defmodule Quic.CodeGrader do

  defp url() do
    "http://localhost:5000/"
  end

  require Logger

  def get_response(participant_id, participant_answer, test_file, tests) do
    case HTTPoison.post(url(), Jason.encode!(%{
      "participant_id" => participant_id,
      "participant_answer" => participant_answer,
      "test_file" => test_file,
      "tests" => tests
    }), [{"Content-Type", "application/json"}]) do
      {:ok, response} ->
        case Jason.decode(response.body) do
          {:ok, response} ->
            if response["result"] do
              {:ok, String.to_atom(response["result"])}
            else
              if response["detail"] do
                {:error, response["detail"]}
              end
            end
          {:error, _error} -> {:error, "Server Bad Response"}
        end
      {:error, _error} -> {:error, "Server Internal Error"}
    end
  end

end
