defmodule Addict.Interactors.ValidatePassword do
  @moduledoc """
  Validates a password according to the defined strategies.
  For now, only the `:default` strategy exists: password must be at least 6 chars long.

  Returns `{:ok, []}` or `{:error, [errors]}`
  """

  @password_length            8
  @uppercase_condition_regex ~r/[A-Z]+/
  @lowercase_condition_regex ~r/[a-z]+/
  @number_condition_regex    ~r/\d+/
  @special_characters_regex  ~r/[.,!?@#$%^&*()<>]+/
  @password_regex_validations [
    @uppercase_condition_regex,
    @lowercase_condition_regex,
    @number_condition_regex,
    @special_characters_regex
  ]

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

  defp validate(:frame_password, :length, password) when is_bitstring(password) do
    if String.length(password) > @password_length - 1,
      do: [],
      else: [{:password, {"must be at least #{@password_length} characters long", []}}]
  end

  defp validate(:frame_password, :uppercase, password) when is_bitstring(password) do
    if Regex.match?(@uppercase_condition_regex, password),
      do: [],
      else: [{:password, {"must contain at least one uppercase letter", []}}]
  end

  defp validate(:frame_password, :lowercase, password) when is_bitstring(password) do
    if Regex.match?(@lowercase_condition_regex, password),
      do: [],
      else: [{:password, {"must contain at least one lowercase letter", []}}]
  end

  defp validate(:frame_password, :numbers, password) when is_bitstring(password) do
    if Regex.match?(@number_condition_regex, password),
      do: [],
      else: [{:password, {"must contain at least one digit", []}}]
  end

  defp validate(:frame_password, :special_chars, password) when is_bitstring(password) do
    if Regex.match?(@special_characters_regex, password),
      do: [],
      else: [{:password, {"must contain at least one special character", []}}]
  end

  defp validate(:default, password) when is_bitstring(password) do
    if String.length(password) > 5, do: [], else: [{:password, {"is too short", []}}]
  end

  defp validate(:default, changeset) do
    Ecto.Changeset.validate_change(changeset, :password, fn (_field, value) ->
      validate(:default, value)
    end).errors
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
    |> Enum.count(fn valid? -> valid? end)
    |> case do
        num when num < 3 -> [{:password, {"must contain at least one uppercase, lowercase letter, number and special character", []}}]
        _                -> []
      end
  end
end
