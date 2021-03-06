defmodule Addict.Configs do
  @moduledoc false
  [
    :secret_key,
    :generate_csrf_token,
    :password_strategies,
    :not_logged_in_url,
    :user_schema,
    :post_register,
    :post_login,
    :post_logout,
    :post_reset_password,
    :post_recover_password,
    :extra_validation,
    :extra_login_validation,
    :before_login_validation,
    :mail_service,
    :from_email,
    :host,
    :email_register_subject,
    :email_register_template,
    :email_reset_password_subject,
    :email_reset_password_template,
    :reset_password_path,
    :repo,
    :password_reset_token_time_to_expiry
  ]
  |> Enum.each(fn key ->
    def unquote(key)() do
      Application.get_env(:addict, unquote(key))
    end
  end)

  def password_hasher do
    Application.get_env(:addict, :password_hasher, Pbkdf2)
  end
end
