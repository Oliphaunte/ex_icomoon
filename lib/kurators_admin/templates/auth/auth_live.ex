defmodule KuratorsAdmin.AuthLive do
  use KuratorsAdmin, :live_view

  require Logger

  alias Kurators.Auth.{SignInCode, TokenHandler, CreateSignInCode, CheckSignInCode}

  @impl true
  def mount(_params, %{"session_uuid" => session_uuid}, socket) do
    socket =
      socket
      |> assign(:session_uuid, session_uuid)
      |> assign(:email_changeset, CreateSignInCode.changeset())
      |> assign(:code_changeset, CheckSignInCode.changeset())
      |> assign(:remember_me, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("sso", %{"value" => provider}, socket) do
    case Kurators.Auth.authorize_url(provider) do
      {:ok, response} ->
        {:noreply, redirect(socket, external: response.url)}

      {:error, _error} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("remember_me", %{"value" => value}, socket) do
    {:noreply, assign(socket, remember_me: if(value, do: true, else: false))}
  end

  @impl true
  def handle_event("submit_email", %{"create_sign_in_code" => user_params}, socket) do
    with {:ok, %{email: email}} <- CreateSignInCode.validate(user_params),
         {:ok, %{id: id}} <- Kurators.Auth.authenticate(email) do
      {:noreply, assign(socket, email: email, sign_in_code_id: id)}
    else
      {:error, changeset} ->
        {:noreply, assign(socket, email_changeset: changeset)}
    end
  end

  @impl true
  def handle_event("submit_code", %{"check_sign_in_code" => params}, socket) do
    %{remember_me: remember_me, sign_in_code_id: sign_in_code_id, session_uuid: session_uuid} =
      socket.assigns

    with {:ok, %{code: code}} <- CheckSignInCode.validate(params),
         {:ok, %{user_id: user_id}} <- SignInCode.check_sign_in_code(sign_in_code_id, code),
         :ok <- TokenHandler.add_token(session_uuid, user_id, remember_me) do
      {:noreply, push_redirect(socket, to: "/", replace: true)}
    else
      {:error, changeset} ->
        {:noreply, assign(socket, code_changeset: changeset)}
    end
  end
end
