defmodule Addict.Interactors.CreateSession do
  @moduledoc """
  Adds `user` as `:current_user` to the session in `conn`

  Returns `{:ok, conn}`
  """

  import Plug.Conn

  def call(conn, user, schema \\ Addict.Configs.user_schema()) do
    conn =
      conn
      |> fetch_session
      |> put_session(:current_user, Addict.Presenter.strip_all(user, schema))

    {:ok, conn}
  end
end
