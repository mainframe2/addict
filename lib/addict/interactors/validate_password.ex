defmodule Addict.Interactors.ValidatePassword do

  @doc """
  Validates a password according to the defined strategies.
  For now, only the `:default` strategy exists: password must be at least 6 chars long.

  Returns `{:ok, []}` or `{:error, [errors]}`
  """
  def call(changeset, nil) do
    call(changeset, [])
  end

  def call(changeset, strategies) do
    strategies =
      case Enum.count(strategies) do
        0 -> [:default]
        _ -> strategies
      end

    strategies
    |> Enum.reduce(changeset, fn (strategy, acc) ->
      validate(strategy, acc)
    end)
    |> format_response
  end

  defp format_response([]) do
    {:ok, []}
  end

  defp format_response(messages) do
    {:error, messages}
  end

  defp validate(:default, password) when is_bitstring(password) do
    if String.length(password) > 5, do: [], else: [{:password, {"is too short", []}}]
  end

  defp validate(:default, changeset) do
    Ecto.Changeset.validate_change(changeset, :password, fn (_field, value) ->
      validate(:default, value)
    end).errors
  end

  @uppercase_condition_regex ~r/[A-Z]+/
  @lowercase_condition_regex ~r/[a-z]+/
  @number_condition_regex    ~r/d+/
  @special_characters_regex  ~r/[.,!?@#$%^&*()<>]+/
  @password_regex_validations [@uppercase_condition_regex, @lowercase_condition_regex, @number_condition_regex, @special_characters_regex]

  defp validate(:frame_password, :length, password) when is_bitstring(password) do
    if String.length(password) > 7, do: [], else: [{:password, {"is too short", []}}]
  end

  defp validate(:frame_password, :uppercase, password) when is_bitstring(password) do
    if Regex.match?(~r/[A-Z]+/, password), do: [], else: [{:password, {"must contain at least one uppercase letter", []}}]
  end

  defp validate(:frame_password, :lowercase, password) when is_bitstring(password) do
    if Regex.match?(~r/[a-z]+/, password), do: [], else: [{:password, {"must contain at least one lowercase letter", []}}]
  end

  defp validate(:frame_password, :numbers, password) when is_bitstring(password) do
    if Regex.match?(~r/d+/, password), do: [], else: [{:password, {"must contain at least one digit", []}}]
  end

  defp validate(:frame_password, :special_chars, password) when is_bitstring(password) do
    if Regex.match?(~r/[.,!@#$%^&*()]+/, password), do: [], else: [{:password, {"must contain at least one special character", []}}]
  end

  defp validate(:frame_password, changeset) do
    Ecto.Changeset.validate_change(changeset, :password, fn (_field, value) ->
      value |> validate_frame_password
    end).errors
  end

  defp validate_frame_password(password) when is_bitstring(password) do
    case validate(:frame_password, :length, password) do
      []      -> password |> validate_frame_password_complexity
      [error] -> [error]
    end
  end

  defp validate_frame_password_complexity(password) do
    Enum.map(@password_regex_validations, fn regex -> Regex.match?(regex, password) end)
    |> IO.inspect
    |> Enum.count(fn valid? -> valid? end)
    |> case do
        num when num < 4 -> [{:password, {"password incomplex", []}}]
        _                -> []
      end
  end

end
