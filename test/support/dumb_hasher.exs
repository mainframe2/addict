defmodule TestDumbHasher do
  @moduledoc """
  A dumb password hasher for testing purposes
  """

  def hash_pwd_salt(password) do
    "dumb-#{password}-password"
  end

  def verify_pass(password, salt) do
    salt == hash_pwd_salt(password)
  end
end
