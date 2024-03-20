defmodule QuicWeb.SessionParticipant do

  alias Quic.Participants
  #alias Quic.Participants.Participant

  def create_participant(session, username) do
    participant = %{"name" => username}
    Participants.create_participant(participant, session)
  end
end
