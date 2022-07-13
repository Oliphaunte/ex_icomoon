defmodule KuratorsAdmin.VerificationEmail do
  use Phoenix.Swoosh,
    template_root: "lib/kurators_admin/templates/email",
    template_path: "auth"

  @doc """
  Generates an email using the login template.
  """
  def verification_code(user, code) do
    site_name = Application.get_env(:kurators, :site_name)
    url = Application.get_env(:kurators, :url)

    new()
    |> to(user.email)
    |> from(from_email())
    |> subject("Verification Code")
    |> render_body("verification.html", %{user: user, code: code, url: url, site_name: site_name})
  end

  defp from_email() do
    {Application.get_env(:kurators, :email_from_name),
     Application.get_env(:kurators, :email_from_address)}
  end
end
