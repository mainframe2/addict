defmodule Addict.Interactors.UpdateUserPassword do
  @moduledoc """
  Updates the user `encrypted_password`

  Returns `{:ok, user}` or `{:error, [errors]}`
  """

  import Ecto.Changeset
  alias Addict.Interactors.GenerateEncryptedPassword

  def call(user, password, first_name, last_name, repo \\ Addict.Configs.repo) do
    user
    |> Ecto.Changeset.change([first_name: first_name,
                              last_name: last_name,
                              encrypted_password: GenerateEncryptedPassword.call(password)])
    |> validate_required(~w(first_name last_name encrypted_password)a)
    |> repo.update
  end

  def call(user, password, repo \\ Addict.Configs.repo) do
    user
    |> Ecto.Changeset.change(encrypted_password: GenerateEncryptedPassword.call(password))
    |> repo.update
  end

end
