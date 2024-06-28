defmodule Quic.CodeGrader do

  defp url() do
    "http://localhost:5000/test"
  end

  def get_response(participant_id, participant_answer, test_file, tests) do
    case HTTPoison.post(url(), Jason.encode!(%{
      "id" => participant_id,
      "answer" => participant_answer,
      "test_file" => test_file,
      "tests" => tests
    }), [{"Content-Type", "application/json"}]) do
      {:ok, response} ->
        case Jason.decode(response.body) do
          {:ok, response} ->
            if response["result"] do
              handle_result(response["result"], response)
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

  def handle_result(result, response) do
    case result do
      "correct" -> {:ok, :correct}
      "incorrect" -> {:failed, response["detail"]}
    end
  end

end
