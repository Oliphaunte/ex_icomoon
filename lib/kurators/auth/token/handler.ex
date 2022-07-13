defmodule Kurators.Auth.TokenHandler do
  use GenServer

  alias Kurators.Auth.{Token}

  def start_link(opts \\ []) do
    GenServer.start_link(
      __MODULE__,
      [
        {:ets_table_name, :token_table}
      ],
      name: __MODULE__
    )
  end

  def add_token(session_uuid, user_id, remember_me) do
    GenServer.call(__MODULE__, {:add_token, session_uuid, user_id, remember_me})
  end

  def delete_token(session_token) do
    GenServer.call(__MODULE__, {:delete_token, session_token})
  end

  def check_token(session_token, access_token) do
    GenServer.call(__MODULE__, {:check_token, session_token, access_token})
  end

  def check_token(session_token) do
    GenServer.call(__MODULE__, {:check_token, session_token})
  end

  ## Callbacks

  @impl true
  def init(args) do
    [{:ets_table_name, ets_table_name}] = args

    :ets.new(ets_table_name, [:named_table, :set, :public])

    {:ok, %{ets_table_name: ets_table_name}}
  end

  @impl true
  def handle_call({:add_token, session_uuid, user_id, remember_me}, _from, state) do
    {:ok, session_token} = Token.generate_token(%{id: user_id})

    :ets.insert(
      :token_table,
      {:"#{session_uuid}", %{session_token: session_token, remember_me: remember_me}}
    )

    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:delete_token, session_token}, _from, state) do
    Token.delete_session_token(session_token)

    {:reply, :ok, state}
  end

  def handle_call({:check_token, session_token, access_token}, _from, state) do
    case Token.check_token(session_token, access_token) do
      {:ok, %{access_token: access_token, session_token: session_token, user: user}} ->
        {:reply, {:ok, %{access_token: access_token, session_token: session_token, user: user}},
         state}

      _ ->
        {:reply, :not_found, state}
    end
  end

  def handle_call({:check_token, session_token}, _from, state) do
    case Token.check_token(session_token) do
      {:ok, user} -> {:reply, user, state}
      _ -> {:reply, :not_found, state}
    end
  end

  # this is a leak issue I think, not sure where or why it is happening
  # Kurators.Auth.TokenHandler Kurators.Auth.TokenHandler received unexpected message in handle_info/2: {:ssl,
  # {:sslsocket, {:gen_tcp, #Port<0.173>, :tls_connection, :undefined},
  @impl true
  def handle_info({:ssl, _}, state) do
    {:noreply, state}
  end

  # @impl true
  # def terminate(_reason, %{buffer: buffer} = _state) do
  #   # Phoenix.PubSub.unsubscribe(PubSub, "chat:#{email}")
  # end
end
