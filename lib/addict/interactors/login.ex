defmodule Addict.Interactors.Login do
  @moduledoc """
  Verifies if the `password` is correct for the provided `email`

  Returns `{:ok, user}` or `{:error, [errors]}`
  """

  alias Addict.Interactors.{GetUserByEmail, VerifyPassword}

  def call(%{"email" => email, "password" => password}, configs \\ Addict.Configs) do

    extra_login_validation = configs.extra_login_validation || fn (a) -> {:ok, a} end
    before_login_validation = configs.before_login_validation || fn (a) -> {:ok, a} end

    with {:ok, user} <- GetUserByEmail.call(email),
         {:ok, _} <- Addict.Helper.exec(before_login_validation, [user]),
         {:ok}    <- VerifyPassword.call(user, password),
         {:ok, _} <- Addict.Helper.exec(extra_login_validation, [user]) do
    {:ok, user}
    else
      error -> error
    end
  end
end
