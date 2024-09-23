defmodule QuicWeb.CSVController do
  use QuicWeb, :controller

  alias Quic.Sessions

  def download(conn, %{"session_id" => session_id} = _params) do
    case Sessions.is_owner?(session_id, conn.assigns.current_author) do
      true ->
        session = Sessions.get_session_by_id(session_id)
        participants = Sessions.get_session_participants(session_id)
        csv_content = generate_csv_content(session, participants)

        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header("content-disposition", "attachment; filename=\"session_#{session.code}_results.csv\"")
        |> send_resp(200, csv_content)

      false ->
        conn |> send_resp(404, "Not Found")
    end
  end


  def generate_csv_content(session, participants) do
    header = "Name;Points" <> Enum.reduce(session.quiz.questions, "", fn q, a -> a <> ";Q" <> Integer.to_string(q.position) end) <> "\n"

    participants_content = Enum.reduce(participants, "",
      fn participant,acc ->
        acc <> participant.name <> ";" <> Integer.to_string(participant.total_points) <>
          Enum.reduce(session.quiz.questions, "",
            fn question,acc ->
              answer = Enum.find(participant.answers, nil, fn a -> a.question_id === question.id end)
              has_answered = answer !== nil
              if !has_answered do
                acc <> ";--"
              else
                if answer.result === :correct, do: acc <> ";" <> Integer.to_string(question.points), else: acc <> ";0"
              end
            end
          )
        <> "\n"
      end
    )

    footer = ";Accuracy:" <> Enum.reduce(session.quiz.questions, "",
      fn question,acc ->
        acc <> ";" <> Float.to_string(Sessions.calculate_quiz_question_accuracy(session.id, question.id)) <> "%"
      end
    )

    header <> participants_content <> footer
  end
end
