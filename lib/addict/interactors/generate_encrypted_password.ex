defmodule Addict.Interactors.GenerateEncryptedPassword do
  @moduledoc """
  Securely hashes `password`

  Returns the hash as a String
  """

  def call(password) do
    Addict.Configs.password_hasher().hash_pwd_salt(password)
  end
end
