defmodule TestAddictUser do
  @moduledoc false

  use Ecto.Schema

  schema "users" do
    field(:password, :string)
    field(:email, :string)
  end
end

defmodule RegisterTest do
  @moduledoc false

  alias Addict.Interactors.ValidatePassword
  use ExUnit.Case, async: true

  test "it passes on happy path" do
    changeset = %TestAddictUser{} |> Ecto.Changeset.cast(%{password: "one passphrase"}, ~w(password)a, [])
    assert {:ok, []} = ValidatePassword.call(changeset, [])
  end

  test "it validates the default use case" do
    changeset = %TestAddictUser{} |> Ecto.Changeset.cast(%{password: "123"}, ~w(password)a, [])
    assert {:error, [password: {"is too short", []}]} = ValidatePassword.call(changeset, [])
  end
end
