defmodule Addict.Interactors.InjectHash do
  @moduledoc """
  Adds `"encrypted_password"` and drops `"password"` from provided hash.

  Returns the new hash with `"encrypted_password"` and without `"password"`.
  """

  alias Addict.Interactors.GenerateEncryptedPassword

  def call(user_params) do
    user_params
    |> Map.put("encrypted_password", GenerateEncryptedPassword.call(user_params["password"]))
    |> Map.drop(["password"])
  end
end
