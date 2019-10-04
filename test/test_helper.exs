alias Ecto.Adapters.SQL.Sandbox

Logger.configure(level: :info)
ExUnit.start()

Code.require_file("./support/dumb_hasher.exs", __DIR__)
Code.require_file("./support/schema.exs", __DIR__)
Code.require_file("./support/repo.exs", __DIR__)
Code.require_file("./support/router.exs", __DIR__)
Code.require_file("./support/migrations.exs", __DIR__)

defmodule Addict.RepoSetup do
  use ExUnit.CaseTemplate

  setup do
    :ok = Sandbox.checkout(TestAddictRepo)
    Sandbox.mode(TestAddictRepo, {:shared, self()})
    :ok
  end
end

defmodule Addict.SessionSetup do
  def with_session(conn) do
    session_opts = Plug.Session.init(store: :cookie, key: "_app", encryption_salt: "abc", signing_salt: "abc")

    conn
    |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
    |> Plug.Session.call(session_opts)
    |> Plug.Conn.fetch_session()
  end
end

_ = Ecto.Adapters.Postgres.storage_down(TestAddictRepo.config())
_ = Ecto.Adapters.Postgres.storage_up(TestAddictRepo.config())

{:ok, _pid} = TestAddictRepo.start_link()
_ = Ecto.Migrator.up(TestAddictRepo, 0, TestAddictMigrations, log: false)
Process.flag(:trap_exit, true)
