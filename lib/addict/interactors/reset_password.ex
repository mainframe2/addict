defmodule Addict.Interactors.ResetPassword do
  alias Addict.Interactors.{GetUserById, UpdateUserPassword, ValidatePassword}
  require Logger

  @doc """
  Executes the password reset flow: parameters validation, password hash generation, user updating.

  Returns `{:ok, user}` or `{:error, [errors]}`
  """
  def call(params) do
    token     = params["token"]
    password  = params["password"]
    signature = params["signature"]
    first_name = params["first_name"]
    last_name  = params["last_name"]

    with {:ok} <- validate_params(token, password, signature, first_name, last_name),
         {:ok, true} <- Addict.Crypto.verify(token, signature),
         {:ok, generation_time, user_id} <- parse_token(token),
         {:ok} <- validate_generation_time(generation_time),
         {:ok, _} <- validate_password(password),
         {:ok, user} <- GetUserById.call(user_id),
         {:ok, _} <- update_password(user, password, first_name, last_name),
     do: {:ok, user}
  end

  defp validate_params(token, password, signature, first_name, last_name) do
    if token == nil || password == nil || signature == nil || first_name == "" || last_name == "" do
      Logger.debug("Invalid params for password reset")
      Logger.debug("token: #{token}")
      Logger.debug("password: #{password}")
      Logger.debug("signature: #{signature}")
      Logger.debug("first_name: #{first_name}")
      Logger.debug("last_name: #{last_name}")
      {:error, [{:params, "Invalid params"}]}
    else
      {:ok}
    end
  end

  defp parse_token(token) do
    [generation_time, user_id] = Base.decode16!(token) |> String.split(",")

    id =
    user_id
    |> is_integer()
    |> case do
      true -> Integer.to_string(user_id)
      false -> user_id
    end

    {:ok, String.to_integer(generation_time), id}
  end

  defp validate_generation_time(generation_time) do
    time_to_expiry = if Addict.Configs.password_reset_token_time_to_expiry != nil do
      Addict.Configs.password_reset_token_time_to_expiry
    else
      86_400
    end
    do_validate_generation_time(:erlang.system_time(:seconds) - generation_time <= time_to_expiry)
  end

  defp do_validate_generation_time(true) do
    {:ok}
  end

  defp do_validate_generation_time(false) do
    {:error, [{:token, "Password reset token not valid."}]}
  end

  defp validate_password(password, password_strategies \\ Addict.Configs.password_strategies) do
    %Addict.PasswordUser{}
    |> Ecto.Changeset.cast(%{password: password}, ~w(password), [])
    |> ValidatePassword.call(password_strategies)
    |> _format_response
  end

  defp update_password(user, password, nil, nil),
    do: UpdateUserPassword.call(user, password)

  defp update_password(user, password, first_name, last_name),
    do: UpdateUserPassword.call(user, password, first_name, last_name)

  defp _format_response({:ok, _}=response), do: response
  defp _format_response({:error, [password: {message, _}]}), do: {:error, [{:password, message}]}
  defp _format_response({:error, error}), do: {:error, error}

end
