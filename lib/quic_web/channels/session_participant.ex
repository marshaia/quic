defmodule QuicWeb.SessionParticipant do

  alias Quic.Sessions
  alias Quic.Participants
  alias Quic.ParticipantAnswers

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

  def update_participant_current_question(participant_id) do
    participant = Participants.get_participant!(participant_id)
    participant |> Participants.update_participant(%{"current_question" => participant.current_question + 1})
  end

  def assess_submission(participant_id, question_id, answer) do
    participant = Participants.get_participant!(participant_id)
    question = Enum.find(participant.session.quiz.questions, fn q -> q.id === question_id end)
    question_answers = Enum.filter(participant.session.quiz.answers, fn a -> a.question_id === question_id end)

    #if answer.question.id === question_id do
      case question.type do
        :single_choice ->
          ParticipantAnswers.create_participant_answer(%{"answer" => [answer]}, participant_id, question_id)
          assess_single_choice(question_answers, answer)
        :multiple_choice ->
          ParticipantAnswers.create_participant_answer(%{"answer" => answer}, participant_id, question_id)
          assess_multiple_choice(question_answers, answer)
        :true_false ->
          ParticipantAnswers.create_participant_answer(%{"answer" => [answer]}, participant_id, question_id)
          assess_true_false(question_answers, answer)
        _ -> false
      end
    #else
    #  false
    #end
  end

  def assess_single_choice(question_answers, answer) do
    selected_answer = Enum.find(question_answers, fn a -> a.id === answer end)
    selected_answer.is_correct
  end

  def assess_multiple_choice(question_answers, selected_answers) do
    # question correct answers
    correct_answers = Enum.reduce(question_answers, [], fn a, acc -> if a.is_correct, do: [a.id | acc], else: acc end)
    how_many_true = Enum.count(correct_answers)

    # check participant didn't select incorrect answers
    participant_correct_answers = Enum.reduce(selected_answers, true, fn answer_id, acc -> if !Enum.member?(correct_answers, answer_id), do: false, else: acc end)

    # check if participant selected only correct answers and all correct answers possible
    participant_correct_answers && how_many_true === Enum.count(selected_answers)
  end

  def assess_true_false(question_answers, participant_answer) do
    participant_answer = (if participant_answer === "true", do: true, else: false)
    question_answer = Enum.at(question_answers, 0, nil)
    case question_answer do
      nil -> false
      answer -> answer.is_correct === participant_answer
    end
  end

  require Logger
  def update_participant_results(participant_id, question_id, results) do
    participant = Participants.get_participant!(participant_id)
    question = Enum.find(participant.session.quiz.questions, fn q -> q.id === question_id end)

    Logger.error("\n\nanswers: \n#{inspect participant.answers}\n\n")

    participant_answer = Enum.find(participant.answers, nil, fn a -> a.question_id === question_id end)



    if results do
      participant |> Participants.update_participant(%{"total_points" => participant.total_points + question.points})
      ParticipantAnswers.update_participant_answer(participant_answer, %{"result" => :correct})
    else
      ParticipantAnswers.update_participant_answer(participant_answer, %{"result" => :incorrect})
    end
  end

  def get_participant_next_question(participant_id, current_question) do
    participant = Participants.get_participant!(participant_id)
    session = Sessions.get_session!(participant.session.id)
    quiz_questions = session.quiz.questions

    if Enum.count(quiz_questions) === current_question do
      {:error_max_questions, participant}
    else
      if current_question >= 1 && current_question < Enum.count(quiz_questions) do
        next_question = Enum.find(quiz_questions, nil, fn q -> q.position === current_question + 1 end)
        if next_question !== nil, do: {:ok, next_question}, else: {:error_invalid_question, participant}
      else
        {:error, participant}
      end
    end
  end
end
