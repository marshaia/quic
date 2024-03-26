defmodule QuicWeb.SessionParticipant do
  require Logger

  alias Quic.Participants
  #alias Quic.Participants.Participant

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
end
