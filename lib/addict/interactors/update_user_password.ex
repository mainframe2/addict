defmodule Addict.Interactors.UpdateUserPassword do
  import Ecto.Changeset
  alias Addict.Interactors.GenerateEncryptedPassword
  @doc """
  Updates the user `encrypted_password`

  Returns `{:ok, user}` or `{:error, [errors]}`
  """
  require Logger

  def call(user, password, first_name, last_name, repo \\ Addict.Configs.repo) do
    Logger.warn fn -> "calling update password with fn: #{inspect first_name} and ln: #{inspect last_name}" end
    user
    |> Ecto.Changeset.change([first_name: first_name,
                              last_name: last_name,
                              encrypted_password: GenerateEncryptedPassword.call(password)])
    |> validate_required(~w(first_name last_name encrypted_password)a)
    |> repo.update
  end

  def call(user, password, repo \\ Addict.Configs.repo) do
    Logger.warn fn -> "calling update password with password only" end
    user
    |> Ecto.Changeset.change(encrypted_password: GenerateEncryptedPassword.call(password))
    |> repo.update
  end

end
