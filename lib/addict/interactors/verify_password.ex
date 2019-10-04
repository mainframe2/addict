defmodule Addict.Interactors.VerifyPassword do
  @moduledoc """
  Verifies if the password for the user is valid

  Returns `{:ok}` or `{:error, [authentication: "Incorrect e-mail/password"]}`
  """

  def call(user, password) do
    Addict.Configs.password_hasher.verify_pass(password, user.encrypted_password) |> process_response
  end

  defp process_response(false) do
    {:error, [authentication: "Incorrect e-mail/password"]}
  end

  defp process_response(true) do
    {:ok}
  end
end
