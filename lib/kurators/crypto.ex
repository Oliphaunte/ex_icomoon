defmodule Kurators.Crypto do
  # 1 hour
  @default_ttl 1 * 60 * 60

  @doc "Encrypt any Erlang term"
  @spec encrypt(atom, any) :: binary
  def encrypt(context, term) do
    Plug.Crypto.encrypt(secret(), to_string(context), term)
  end

  @doc "Decrypt cipher-text into an Erlang term"
  @spec decrypt(atom, binary) :: {:ok, any} | {:error, atom}
  def decrypt(context, ciphertext, max_age \\ @default_ttl) when is_binary(ciphertext) do
    Plug.Crypto.decrypt(secret(), to_string(context), ciphertext, max_age: max_age)
  end

  # Update the secret key being used
  # defp secret, do: Application.get_env(:kurators, :secret_key_base)
  defp secret, do: "whnL8JiOu6e5YIbt0mqTHL51OxbBC6DmLAzIrO0RA0LN8AyrLs1MdVtVitIUB6pJ"
end
