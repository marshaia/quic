defmodule Quic.CodeGrader do

  defp url() do
    "http://localhost:8000/"
  end

  require Logger
  def get_hello_world() do
    case HTTPoison.post(url(), Jason.encode!(%{"name" => "Joana"}), [{"Content-Type", "application/json"}]) do
      {:ok, response} ->
        case Jason.decode(response.body) do
          {:ok, response} -> Logger.error("response: #{inspect response}")
          {:error, error} -> Logger.error("error: #{inspect error}")
        end
      {:error, error} -> Logger.error("error: #{inspect error}")
    end
  end
end
