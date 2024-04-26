defmodule QuicWeb.SessionParticipant do
  require Logger

  alias Quic.Sessions
  alias Quic.Questions
  alias Quic.Participants

  def session_is_open?(code) do
    Sessions.is_session_open?(code)
  end

  def create_participant(session, username) do
    participant = %{"name" => username}
    Participants.create_participant(participant, session)
  end

  def get_participant_name(id) do
    Participants.get_participant!(id).name
  end

  def participant_already_in_session?(id, session_code) do
    case Participants.get_participant_session_code!(id) do
      nil ->  false
      code -> session_code === code
    end
  end

  def update_participant_current_question(id) do
    participant = Participants.get_participant!(id)

    if participant.current_question === nil do
      participant |> Participants.update_participant(%{"current_question" => 1})
    else
      participant |> Participants.update_participant(%{"current_question" => participant.current_question + 1})
    end
  end

  def assess_submission(_participant_id, question_id, selected_answer) do
    question = Questions.get_question!(question_id)
    answer = Questions.get_question_answer!(selected_answer)

    if answer.question.id === question_id do
      case question.type do
        :multiple_choice -> assess_multiple_choice(question, answer)
        _ -> false
      end
    else
      false
    end
  end

  def assess_multiple_choice(_question, selected_answer) do
    selected_answer.is_correct
  end

  def update_participant_results(participant_id, question_id, results) do
    if results do
      participant = Participants.get_participant!(participant_id)
      question = Questions.get_question!(question_id)

      participant |> Participants.update_participant(%{"total_points" => participant.total_points + question.points})
    end

  end
end
