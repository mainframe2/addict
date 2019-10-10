defmodule Addict.Interactors.DestroySession do
  @moduledoc """
  Removes `:current_user` from the session in `conn`

  Returns `{:ok, conn}`
  """

  import Plug.Conn

  def call(conn) do
    conn =
      conn
      |> fetch_session
      |> delete_session(:current_user)
      |> assign(:current_user, nil)

    {:ok, conn}
  end
end
