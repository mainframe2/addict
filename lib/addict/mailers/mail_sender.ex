defmodule Addict.Mailers.MailSender do
  @moduledoc """
  Sends register and reset token e-mails
  """
  require Logger

  def send_register(user_params) do
    template =
    case Addict.Configs.email_register_template do
      nil -> "<p>Thanks for registering <%= email %>!</p>"
      {module, method} -> apply(module, method, [user_params])
      text -> text
    end
    subject = Addict.Configs.email_register_subject || "Welcome"
    user = user_params |> convert_to_list
    html_body = EEx.eval_string(template, user)
    from_email = Addict.Configs.from_email || "no-reply@addict.github.io"
    Addict.Mailers.send_email(user_params["email"], from_email, subject, html_body)
  end

  def send_reset_token(email, path, host \\ Addict.Configs.host) do
    host = host || "http://localhost:4000"
    template =
    case Addict.Configs.email_reset_password_template do
      nil -> "<p>You've requested to reset your password. Click <a href='#{host}<%= path %>'>here</a> to proceed!</p>"
      {module, method} -> apply(module, method, [email, path, host])
      text -> text
    end
    subject = Addict.Configs.email_reset_password_subject || "Reset Password"
    params = %{"email" => email, "path" => path} |> convert_to_list
    html_body = EEx.eval_string(template, params)
    from_email = Addict.Configs.from_email || "no-reply@addict.github.io"
    Addict.Mailers.send_email(email, from_email, subject, html_body)
  end

  defp convert_to_list(params) do
    params
    |> Map.to_list
    |> Enum.reduce([], fn ({key, value}, acc) ->
      Keyword.put(acc, String.to_atom(key), value)
    end)
  end

end
