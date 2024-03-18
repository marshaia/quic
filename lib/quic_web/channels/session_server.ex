defmodule QuicWeb.SessionServer do
  use GenServer
  require Logger

  # Client
  # def start_link() do
  #   GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  # end

  def start_session(code) do
    Logger.debug("Joining session #{code}")
    {:ok, pid} = GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

    GenServer.call(__MODULE__, {:start, code, pid})
  end

  def join_session(_participant) do
    GenServer.call(__MODULE__, :join)
  end



  # Server
  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:start, code, pid}, _from, state) do
    Logger.debug("JOINED session #{code}")
    {:reply, pid, state}
  end

  @impl true
  def handle_call(:join, _from, state) do
    Logger.info("Join Call with Participant: #{state}")
    {:reply, state, "joined session successfully"}
  end


end
