defmodule Addict.Interactors.GeneratePasswordResetLink do
  @moduledoc """
  Generates a ready to use password reset path. The generated token is timestamped.

  Returns the password reset path with a token and it's respective signature.
  """

  def call(user_id, secret \\ Addict.Configs.secret_key(), reset_path \\ Addict.Configs.reset_password_path()) do
    current_time = to_string(:erlang.system_time(:seconds))
    reset_string = Base.encode16("#{current_time},#{user_id}")
    reset_path = reset_path || "/reset_password"
    signature = Addict.Crypto.sign(reset_string, secret)
    {:ok, "#{reset_path}?token=#{reset_string}&signature=#{signature}"}
  end
end
